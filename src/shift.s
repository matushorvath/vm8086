.EXPORT execute_rol_b
.EXPORT execute_rol_w
.EXPORT execute_ror_b
.EXPORT execute_ror_w
.EXPORT execute_rcl_b
.EXPORT execute_rcl_w
.EXPORT execute_rcr_b
.EXPORT execute_rcr_w
.EXPORT execute_shl_b
.EXPORT execute_shl_w
.EXPORT execute_shr_b
.EXPORT execute_shr_w
.EXPORT execute_sar_b
.EXPORT execute_sar_w

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From obj/bits.s
.IMPORT bits

# From obj/parity.s
.IMPORT parity

# From obj/shl.s
.IMPORT shl

# From obj/shr.s
.IMPORT shr

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# TODO remove
execute_rol_b:
execute_rol_w:
execute_ror_b:
execute_ror_w:
execute_rcl_b:
execute_rcl_w:
execute_rcr_b:
execute_rcr_w:
execute_shl_w:
execute_shr_b:
execute_shr_w:
execute_sar_b:
execute_sar_w:

##########
execute_shl_b:
.FRAME loc_type_val, loc_addr_val, loc_type_cnt, loc_addr_cnt; val, val_bits, cnt, tmp
    arb -4

    add 0, 0, [flag_auxiliary_carry]

    # Read the number of bits
    add [rb + loc_type_cnt], 0, [rb - 1]
    add [rb + loc_addr_cnt], 0, [rb - 2]
    arb -2
    call read_location_b            # TODO _b even for 16-bit
    add [rb - 4], 0, [rb + cnt]

    # If we are shifting more than 8 bits, use fixed values
    lt  [rb + cnt], 9, [rb + tmp]
    jz  [rb + tmp], execute_shl_b_many

    # Read the value to shift
    add [rb + loc_type_val], 0, [rb - 1]
    add [rb + loc_addr_val], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # If we are shifting by 0, use a simplified algorithm
    jnz [rb + cnt], execute_shl_b_zero

    # Expand val to bits
    mul [rb + val], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + val_bits]

    # Carry flag is the last bit shifted out
    mul [rb + cnt], -1, [rb + tmp]
    add 8, [rb + tmp], [rb + tmp]

    add [rb + val_bits], [rb + tmp], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted value in the shl table
    mul [rb + val], 8, [rb + tmp]
    add shl, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + cnt], [ip + 1]
    add [0], 0, [rb + val]

    # Update flags
    lt  0x7f, [rb + val], [flag_sign]
    eq  [rb + val], 0, [flag_zero]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    # Overflow is 1 when high order bit was changed
    # TODO HW docs say OF is only valid when shifting by one
    eq  [flag_carry], [flag_sign], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_shl_b_store

execute_shl_b_zero:
    # If we are shifting by 0, just calculate the flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    lt  0x7f, [rb + val], [flag_sign]
    eq  [rb + val], 0, [flag_zero]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    jz  0, execute_shl_b_done

execute_shl_b_many:
    # If we are shifting by 9 or more bits, zero the value and use fixed flags
    add 0, 0, [rb + val]

    add 1, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 0, 0, [flag_carry]

execute_shl_b_store:
    # Write the shifted value
    add [rb + loc_type_val], 0, [rb - 1]
    add [rb + loc_addr_val], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_shl_b_done:
    arb 4
    ret 4
.ENDFRAME

.EOF
