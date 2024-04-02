.EXPORT execute_add_b
.EXPORT execute_add_w

.EXPORT execute_adc_b
.EXPORT execute_adc_w

.EXPORT execute_sub_b
.EXPORT execute_sub_w

.EXPORT execute_sbb_b
.EXPORT execute_sbb_w

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
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a, b, res
    arb -3

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

    # Calculate
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    arb -2
    call add_with_carry_b
    add [rb - 4], 0, [rb + res]

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 3
    ret 4
.ENDFRAME

##########
execute_sub_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Clear flag_carry so adc performs a sub without borrow
    add 0, 0, [flag_carry]

    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]
    arb -4
    call execute_sbb_b

    ret 4
.ENDFRAME

##########
execute_sbb_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a, b, res
    arb -3

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

    # Create two's complement of the source value
    jz  [rb + a], execute_sbb_b_after_negate
    mul [rb + a], -1, [rb + a]
    add 0x100, [rb + a], [rb + a]

execute_sbb_b_after_negate:
    # Calculate
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    arb -2
    call add_with_carry_b
    add [rb - 4], 0, [rb + res]

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 3
    ret 4
.ENDFRAME

##########
add_with_carry_b:
.FRAME a, b; res, tmp                                       # returns res
    arb -2

    # Update flag_auxiliary_carry before we modify flag_carry
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    arb -2
    call update_auxiliary_carry

    # Calculate the result
    add [rb + a], [rb + b], [rb + res]
    add [rb + res], [flag_carry], [rb + res]

    # Check for carry
    lt  0xff, [rb + res], [flag_carry]
    jz  [flag_carry], add_with_carry_b_after_carry

    add [rb + res], -0x100, [rb + res]

add_with_carry_b_after_carry:
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

    arb 2
    ret 2
.ENDFRAME

##########
execute_add_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Clear flag_carry so adc performs an add without carry
    add 0, 0, [flag_carry]

    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]
    arb -4
    call execute_adc_w

    ret 4
.ENDFRAME

##########
execute_adc_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a_lo, a_hi, b_lo, b_hi, res_lo, res_hi
    arb -6

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + a_lo]
    add [rb - 5], 0, [rb + a_hi]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + b_lo]
    add [rb - 5], 0, [rb + b_hi]

    # Calculate
    add [rb + a_lo], 0, [rb - 1]
    add [rb + a_hi], 0, [rb - 2]
    add [rb + b_lo], 0, [rb - 3]
    add [rb + b_hi], 0, [rb - 4]
    arb -4
    call add_with_carry_w
    add [rb - 6], 0, [rb + res_lo]
    add [rb - 7], 0, [rb + res_hi]

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res_lo], 0, [rb - 3]
    add [rb + res_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 6
    ret 4
.ENDFRAME

##########
execute_sub_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    # Clear flag_carry so adc performs an add without carry
    add 0, 0, [flag_carry]

    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    add [rb + loc_type_dst], 0, [rb - 3]
    add [rb + loc_addr_dst], 0, [rb - 4]
    arb -4
    call execute_sbb_w

    ret 4
.ENDFRAME

##########
execute_sbb_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a_lo, a_hi, b_lo, b_hi, res_lo, res_hi
    arb -6

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + a_lo]
    add [rb - 5], 0, [rb + a_hi]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + b_lo]
    add [rb - 5], 0, [rb + b_hi]

    # Create two's complement of the source value
    jz  [rb + a_hi], execute_sbb_b_after_negate_hi
    mul [rb + a_hi], -1, [rb + a_hi]
    add 0x100, [rb + a_hi], [rb + a_hi]

execute_sbb_b_after_negate_hi:
    jz  [rb + a_lo], execute_sbb_b_after_negate_lo
    mul [rb + a_lo], -1, [rb + a_lo]
    add 0x100, [rb + a_lo], [rb + a_lo]
    add [rb + a_hi], -1, [rb + a_hi]

execute_sbb_b_after_negate_lo:
    # Calculate
    add [rb + a_lo], 0, [rb - 1]
    add [rb + a_hi], 0, [rb - 2]
    add [rb + b_lo], 0, [rb - 3]
    add [rb + b_hi], 0, [rb - 4]
    arb -4
    call add_with_carry_w
    add [rb - 6], 0, [rb + res_lo]
    add [rb - 7], 0, [rb + res_hi]

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res_lo], 0, [rb - 3]
    add [rb + res_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 6
    ret 4
.ENDFRAME

##########
add_with_carry_w:
.FRAME a_lo, a_hi, b_lo, b_hi; res_lo, res_hi, tmp          # returns res_lo, res_hi
    arb -3

    # Update flag_auxiliary_carry before we modify flag_carry
    add [rb + a_lo], 0, [rb - 1]
    add [rb + b_lo], 0, [rb - 2]
    arb -2
    call update_auxiliary_carry

    # Calculate the result
    add [rb + a_lo], [rb + b_lo], [rb + res_lo]
    add [rb + res_lo], [flag_carry], [rb + res_lo]
    add [rb + a_hi], [rb + b_hi], [rb + res_hi]

    # Check for carry out of low byte
    lt  0xff, [rb + res_lo], [rb + tmp]
    jz  [rb + tmp], add_with_carry_w_after_carry_lo

    add [rb + res_lo], -0x100, [rb + res_lo]
    add [rb + res_hi], 1, [rb + res_hi]

add_with_carry_w_after_carry_lo:
    # Check for carry out of high byte
    lt  0xff, [rb + res_hi], [flag_carry]
    jz  [flag_carry], add_with_carry_w_after_carry_hi

    add [rb + res_hi], -0x100, [rb + res_hi]

add_with_carry_w_after_carry_hi:
    # Update flags
    lt  0x7f, [rb + res_hi], [flag_sign]

    add [rb + res_lo], [rb + res_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + res_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Update flag_overflow
    add [rb + a_hi], 0, [rb - 1]
    add [rb + b_hi], 0, [rb - 2]
    add [rb + res_hi], 0, [rb - 3]
    arb -3
    call update_overflow

    arb 3
    ret 4
.ENDFRAME

##########
update_auxiliary_carry:
.FRAME a, b; a4l, b4l, tmp
    arb -3

    # Find low-order half-byte of a and b
    mul [rb + a], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + a4l]

    mul [rb + b], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + b4l]

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
    lt  0x7f, [rb + b], [rb + b]
    lt  0x7f, [rb + res], [rb + res]

    eq  [rb + a], [rb + b], [rb + tmp]
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
