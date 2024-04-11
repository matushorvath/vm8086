.EXPORT execute_rol_1_w
.EXPORT execute_rol_cl_w
.EXPORT execute_ror_1_w
.EXPORT execute_ror_cl_w
.EXPORT execute_rcl_1_w
.EXPORT execute_rcl_cl_w
.EXPORT execute_rcr_1_w
.EXPORT execute_rcr_cl_w
.EXPORT execute_shl_1_w
.EXPORT execute_shl_cl_w
.EXPORT execute_shr_1_w
.EXPORT execute_shr_cl_w
.EXPORT execute_sar_1_w
.EXPORT execute_sar_cl_w

# From location.s
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
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# TODO remove
execute_rol_1_w:
execute_ror_1_w:
execute_rcl_1_w:
execute_rcr_1_w:
execute_rol_cl_w:
execute_ror_cl_w:
execute_rcl_cl_w:
execute_rcr_cl_w:

##########
.FRAME loc_type, loc_addr; val_lo, val_hi, val_bits_lo, val_bits_hi, count, spill, tmp
    # Function with multiple entry points

execute_shl_1_w:
    arb -7
    add 1, 0, [rb + count]
    jz  0, execute_shl_w

execute_shl_cl_w:
    arb -7
    add [reg_cl], 0, [rb + count]

execute_shl_w:
    add 0, 0, [flag_auxiliary_carry]

    # If we are shifting more than 16 bits, use fixed values
    lt  [rb + count], 17, [rb + tmp]
    jz  [rb + tmp], execute_shl_w_many

    # Read the value to shift
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val_lo]
    add [rb - 5], 0, [rb + val_hi]

    # If we are shifting by 0, use a simplified algorithm
    jz  [rb + count], execute_shl_w_0

    # Expand val to bits
    mul [rb + val_lo], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + val_bits_lo]
    mul [rb + val_hi], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + val_bits_hi]

    # If we are shifting by 8 or 16, use a simplified algorithm
    eq  [rb + count], 8, [rb + tmp]
    jnz [rb + tmp], execute_shl_w_8
    eq  [rb + count], 16, [rb + tmp]
    jnz [rb + tmp], execute_shl_w_16

    # If we are shifting by 1-7, we need to calculate both bytes
    lt  [rb + count], 8, [rb + tmp]
    jz  [rb + tmp], execute_shl_w_8_to_15

    # Carry flag is the last bit shifted out of hi byte
    mul [rb + count], -1, [rb + tmp]
    add 8, [rb + tmp], [rb + spill]
    add [rb + val_bits_hi], [rb + spill], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted hi value in the shl table
    mul [rb + val_hi], 7, [rb + tmp]
    add shl, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]        # TODO consider including shift by 0 in the tables, to save instructions
    add [0], 0, [rb + val_hi]

    # Shift the lo value right to calculate carry from lo to hi
    mul [rb + val_lo], 7, [rb + tmp]
    add shr, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + spill], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], [rb + val_hi], [rb + val_hi]

    # Find shifted lo value in the shl table
    mul [rb + val_lo], 7, [rb + tmp]
    add shl, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], 0, [rb + val_lo]

    jz  0, execute_shl_w_update_flags

execute_shl_w_8_to_15:
    # Shifting by 8-15, shift the lo byte by (count - 8) and store it in hi byte
    add [rb + count], -8, [rb + count]

    # Carry flag is the last bit shifted out of lo byte
    mul [rb + count], -1, [rb + tmp]
    add 8, [rb + tmp], [rb + spill]
    add [rb + val_bits_lo], [rb + spill], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted lo value in the shl table and use it as hi value
    mul [rb + val_lo], 7, [rb + tmp]
    add shl, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], 0, [rb + val_hi]

    # Zero the lo value
    add 0, 0, [rb + val_lo]

    jz  0, execute_shl_w_update_flags

execute_shl_w_8:
    # If we are shifting by 8, move the lo byte to hi byte and zero the lo byte, then update flags
    add [rb + val_lo], 0, [rb + val_hi]
    add 0, 0, [rb + val_lo]

    add [rb + val_bits_hi], 0, [ip + 1]
    add [0], 0, [flag_carry]

execute_shl_w_update_flags:
    # Update flags
    lt  0x7f, [rb + val_hi], [flag_sign]
    add [rb + val_lo], [rb + val_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + val_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Overflow flag is 1 when high order bit was changed
    eq  [flag_carry], [flag_sign], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_shl_w_store

execute_shl_w_0:
    # If we are shifting by 0, SF ZF and PF are not affected
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_shl_w_done

execute_shl_w_16:
    # If we are shifting by 16, zero the value and use fixed flags except for CF
    add [rb + val_bits_lo], 0, [ip + 1]
    add [0], 0, [flag_carry]

    eq  [flag_carry], 1, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val_lo]
    add 0, 0, [rb + val_hi]

    jz  0, execute_shl_w_store

execute_shl_w_many:
    # If we are shifting by 17 or more bits, zero the value and use fixed flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val_lo]
    add 0, 0, [rb + val_hi]

execute_shl_w_store:
    # Write the shifted value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_shl_w_done:
    arb 7
    ret 2
.ENDFRAME

##########
.FRAME loc_type, loc_addr; val_lo, val_hi, val_bits_lo, val_bits_hi, count, spill, tmp
    # Function with multiple entry points

execute_shr_1_w:
    arb -7
    add 1, 0, [rb + count]
    jz  0, execute_shr_w

execute_shr_cl_w:
    arb -7
    add [reg_cl], 0, [rb + count]

execute_shr_w:
    add 0, 0, [flag_auxiliary_carry]

    # If we are shifting more than 16 bits, use fixed values
    lt  [rb + count], 17, [rb + tmp]
    jz  [rb + tmp], execute_shr_w_many

    # Read the value to shift
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val_lo]
    add [rb - 5], 0, [rb + val_hi]

    # If we are shifting by 0, use a simplified algorithm
    jz  [rb + count], execute_shr_w_0

    # Expand val to bits
    mul [rb + val_lo], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + val_bits_lo]
    mul [rb + val_hi], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + val_bits_hi]

    # If we are shifting by 8 or 16, use a simplified algorithm
    eq  [rb + count], 8, [rb + tmp]
    jnz [rb + tmp], execute_shr_w_8
    eq  [rb + count], 16, [rb + tmp]
    jnz [rb + tmp], execute_shr_w_16

    # Overflow flag is 1 when high order bit was changed,
    # and it will be changed to 0 if it is currently 1
    lt  0x7f, [rb + val_hi], [flag_overflow]

    # If we are shifting by 1-7, we need to calculate both bytes
    lt  [rb + count], 8, [rb + tmp]
    jz  [rb + tmp], execute_shr_w_8_to_15

    # Carry flag is the last bit shifted out of lo byte
    add [rb + count], -1, [rb + tmp]
    add [rb + val_bits_lo], [rb + tmp], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted lo value in the shr table
    mul [rb + val_lo], 7, [rb + tmp]
    add shr, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]        # TODO consider including shift by 0 in the tables, to save instructions
    add [0], 0, [rb + val_lo]

    # Shift the hi value left to calculate carry from hi to lo
    mul [rb + count], -1, [rb + tmp]
    add 8, [rb + tmp], [rb + spill]

    mul [rb + val_hi], 7, [rb + tmp]
    add shl, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + spill], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], [rb + val_lo], [rb + val_lo]

    # Find shifted hi value in the shr table
    mul [rb + val_hi], 7, [rb + tmp]
    add shr, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], 0, [rb + val_hi]

    jz  0, execute_shr_w_update_flags

execute_shr_w_8_to_15:
    # Shifting by 8-15, shift the hi byte by (count - 8) and store it in lo byte
    add [rb + count], -8, [rb + count]

    # Carry flag is the last bit shifted out of hi byte
    add [rb + count], -1, [rb + tmp]
    add [rb + val_bits_hi], [rb + tmp], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted hi value in the shr table and use it as lo value
    mul [rb + val_hi], 7, [rb + tmp]
    add shr, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], 0, [rb + val_lo]

    # Zero the hi value
    add 0, 0, [rb + val_hi]

    jz  0, execute_shr_w_update_flags

execute_shr_w_8:
    # If we are shifting by 8, move the hi byte to lo byte and zero the hi byte, then update flags
    add [rb + val_hi], 0, [rb + val_lo]
    add 0, 0, [rb + val_hi]

    add [rb + val_bits_lo], 7, [ip + 1]
    add [0], 0, [flag_carry]

execute_shr_w_update_flags:
    # Update flags
    lt  0x7f, [rb + val_hi], [flag_sign]
    add [rb + val_lo], [rb + val_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + val_lo], [ip + 1]
    add [0], 0, [flag_parity]

    jz  0, execute_shr_w_store

execute_shr_w_0:
    # If we are shifting by 0, SF ZF and PF are not affected
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_shr_w_done

execute_shr_w_16:
    # If we are shifting by 16, zero the value and use fixed flags except for CF
    add [rb + val_bits_hi], 7, [ip + 1]
    add [0], 0, [flag_carry]

    eq  [flag_carry], 1, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val_lo]
    add 0, 0, [rb + val_hi]

    jz  0, execute_shr_w_store

execute_shr_w_many:
    # If we are shifting by 17 or more bits, zero the value and use fixed flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val_lo]
    add 0, 0, [rb + val_hi]

execute_shr_w_store:
    # Write the shifted value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_shr_w_done:
    arb 7
    ret 2
.ENDFRAME

##########
.FRAME loc_type, loc_addr; val, val_bits, count, tmp
    # Function with multiple entry points

execute_sar_1_w:
    arb -4
    add 1, 0, [rb + count]
    jz  0, execute_sar_w

execute_sar_cl_w:
    arb -4
    add [reg_cl], 0, [rb + count]

execute_sar_w:
    hlt # TODO
    add 0, 0, [flag_auxiliary_carry]

    # Read the value to shift
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val]

    # If we are shifting by 0, use a simplified algorithm
    jz  [rb + count], execute_sar_w_zero

    # Sign flag will remain unchanged
    lt  0x7f, [rb + val], [flag_sign]

    # If we are shifting more than 8 bits, use fixed values
    lt  [rb + count], 9, [rb + tmp]
    jz  [rb + tmp], execute_sar_w_many

    # Expand val to bits
    mul [rb + val], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + val_bits]

    # If we are shifting by 8, use a simplified algorithm
    eq  [rb + count], 8, [rb + tmp]
    jnz [rb + tmp], execute_sar_w_sixteen

    # Carry flag is the last bit shifted out
    add [rb + count], -1, [rb + tmp]
    add [rb + val_bits], [rb + tmp], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted value in the sar table
    mul [rb + val], 7, [rb + tmp]
    add shr, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [rb + tmp]
    add [rb + tmp], -1, [ip + 1]
    add [0], 0, [rb + val]

    # If the value was negative, fill the right side with ones, not zeros
    add ones, [rb + count], [ip + 1]
    mul [0], [flag_sign], [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    # Update flags
    eq  [rb + val], 0, [flag_zero]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    # Overflow flag is always 0 because we never change the high order bit
    add 0, 0, [flag_overflow]

    jz  0, execute_sar_w_store

execute_sar_w_zero:
    # If we are shifting by 0, SF ZF and PF are not affected
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_sar_w_done

execute_sar_w_sixteen:
    # If we are shifting by 8, fill the value with the sign bit and use fixed flags except for CF
    add [rb + val_bits], 7, [ip + 1]
    add [0], 0, [flag_carry]

    add 0, 0, [flag_overflow]
    eq  [flag_sign], 0, [flag_zero]
    add 1, 0, [flag_parity]

    mul [flag_sign], 0xff, [rb + val]

    jz  0, execute_sar_w_store

execute_sar_w_many:
    # If we are shifting by 9 or more bits, fill the value with the sign bit and use fixed flags
    add [flag_sign], 0, [flag_carry]
    add 0, 0, [flag_overflow]
    eq  [flag_sign], 0, [flag_zero]
    add 1, 0, [flag_parity]

    mul [flag_sign], 0xff, [rb + val]

execute_sar_w_store:
    # Write the shifted value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_w

execute_sar_w_done:
    arb 4
    ret 2
.ENDFRAME

##########
ones:
    db  0b00000000, 0b10000000, 0b11000000, 0b11100000
    db  0b11110000, 0b11111000, 0b11111100, 0b11111110

.EOF
