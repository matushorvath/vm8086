.EXPORT execute_add_b
.EXPORT execute_adc_b

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From obj/nibbles.s
.IMPORT nibbles

# From obj/parity.s
.IMPORT parity

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

##########
execute_add_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Clear flag_carry so adc performs an add without carry
    add 0, 0, [flag_carry]

    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]
    arb -4
    call execute_adc_b

    ret 4
.ENDFRAME

##########
execute_adc_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a, b, res, tmp
    arb -4

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + a]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + b]

    # TODO BCD

    # Update flag_auxiliary_carry before we modify flag_carry
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    arb -2
    call update_auxiliary_carry_adc

    # Calculate the result
    add [rb + a], [rb + b], [rb + res]
    add [flag_carry], [rb + res], [rb + res]

    # Set carry flag if sum > 0xff
    lt  0xff, [rb + res], [flag_carry]

    # If carry, reduce sum by 0x100
    jz  [flag_carry], execute_adc_b_after_carry
    add [rb + res], -0x100, [rb + res]

execute_adc_b_after_carry:
    # Update flags
    lt  0x7f, [rb + res], [flag_sign]
    eq  [rb + res], 0, [flag_zero]

    add parity, [rb + res], [ip + 1]
    add [0], 0, [flag_parity]

    # Update flag_overflow
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

execute_bitwise_b_end:
    arb 4
    ret 4
.ENDFRAME

##########
update_auxiliary_carry_adc:
.FRAME a, b; a4l, b4l, tmp
    arb -3

    # Find low-order half-byte of a and b
    mul [rb + a], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    eq  [0], 0, [rb + a4l]

    mul [rb + b], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    eq  [0], 0, [rb + b4l]

    # Sum a4l, b4l and carry
    add [rb + a4l], [rb + b4l], [rb + tmp]
    add [flag_carry], [rb + tmp], [rb + tmp]

    # Set auxiliary carry flag if sum > 0xf
    lt  0xf, [rb + tmp], [flag_auxiliary_carry]

    arb 3
    ret 2
.ENDFRAME

##########
update_overflow:
.FRAME a, b, res; tmp
    arb -1

    # TODO this is taken from 6502, validate the algorithm is the same for 8086

    lt  0x7f, [rb + a], [rb + a]
    lt  0x7f, [rb + a], [rb + a]
    lt  0x7f, [rb + res], [rb + res]

    eq  [rb + a], [rb + a], [rb + tmp]
    jnz [rb + tmp], update_overflow_same_sign

    # When operands are different signs, overflow is always false
    add 0, 0, [flag_overflow]
    jz  0, update_overflow_done

update_overflow_same_sign:
    # When operands are the same sign but different than the result, overflow is true
    eq  [rb + a], [rb + res], [rb + tmp]
    eq  [rb + tmp], 0, [flag_overflow]

update_overflow_done:
    arb 1
    ret 3
.ENDFRAME

.EOF
