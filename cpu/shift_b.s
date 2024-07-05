.EXPORT execute_shl_1_b
.EXPORT execute_shl_cl_b
.EXPORT execute_shr_1_b
.EXPORT execute_shr_cl_b
.EXPORT execute_sar_1_b
.EXPORT execute_sar_cl_b

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b

# From util/bits.s
.IMPORT bits
.IMPORT bit_0
.IMPORT bit_7

# From util/parity.s
.IMPORT parity

# From util/shl.s
.IMPORT shl

# From util/shr.s
.IMPORT shr

# From state.s
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

##########
.FRAME lseg, loff; val, count, tmp
    # Function with multiple entry points

execute_shl_1_b:
    arb -3
    add 1, 0, [rb + count]
    jz  0, execute_shl_b

execute_shl_cl_b:
    arb -3
    add [reg_cl], 0, [rb + count]

execute_shl_b:
    add 0, 0, [flag_auxiliary_carry]

    # If we are shifting more than 8 bits, use fixed values
    lt  [rb + count], 9, [rb + tmp]
    jz  [rb + tmp], execute_shl_b_many

    # Read the value to shift
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # If we are shifting by 0, use a simplified algorithm
    jz  [rb + count], execute_shl_b_zero

    # If we are shifting by 8, use a simplified algorithm
    eq  [rb + count], 8, [rb + tmp]
    jnz [rb + tmp], execute_shl_b_eight

    # Carry flag is the last bit shifted out
    mul [rb + count], -1, [rb + tmp]
    add 8, [rb + tmp], [rb + tmp]

    # Get tmp-th bit of val
    add bits, [rb + tmp], [ip + 1]
    add [0], [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted value in the shl table
    mul [rb + val], 8, [rb + tmp]
    add shl, [rb + tmp], [rb + tmp]
    add [rb + tmp], [rb + count], [ip + 1]
    add [0], 0, [rb + val]

    # Update flags
    lt  0x7f, [rb + val], [flag_sign]
    eq  [rb + val], 0, [flag_zero]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    # Overflow flag is 1 when high order bit was changed
    eq  [flag_carry], [flag_sign], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_shl_b_store

execute_shl_b_zero:
    # If we are shifting by 0, SF ZF and PF are not affected
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_shl_b_done

execute_shl_b_eight:
    # If we are shifting by 8, zero the value and use fixed flags except for CF
    add bit_0, [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    eq  [flag_carry], 1, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val]

    jz  0, execute_shl_b_store

execute_shl_b_many:
    # If we are shifting by 9 or more bits, zero the value and use fixed flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val]

execute_shl_b_store:
    # Write the shifted value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_shl_b_done:
    arb 3
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; val, count, tmp
    # Function with multiple entry points

execute_shr_1_b:
    arb -3
    add 1, 0, [rb + count]
    jz  0, execute_shr_b

execute_shr_cl_b:
    arb -3
    add [reg_cl], 0, [rb + count]

execute_shr_b:
    add 0, 0, [flag_auxiliary_carry]

    # If we are shifting more than 8 bits, use fixed values
    lt  [rb + count], 9, [rb + tmp]
    jz  [rb + tmp], execute_shr_b_many

    # Read the value to shift
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # If we are shifting by 0, use a simplified algorithm
    jz  [rb + count], execute_shr_b_zero

    # If we are shifting by 8, use a simplified algorithm
    eq  [rb + count], 8, [rb + tmp]
    jnz [rb + tmp], execute_shr_b_eight

    # Overflow flag is 1 when high order bit was changed,
    # and it will be changed to 0 if it is currently 1
    lt  0x7f, [rb + val], [flag_overflow]

    # Carry flag is the last bit shifted out
    add [rb + count], -1, [rb + tmp]

    # Get tmp-th bit of val
    add bits, [rb + tmp], [ip + 1]
    add [0], [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted value in the shr table
    add shr, [rb + count], [ip + 1]
    add [0], [rb + val], [ip + 1]
    add [0], 0, [rb + val]

    # Update flags
    lt  0x7f, [rb + val], [flag_sign]
    eq  [rb + val], 0, [flag_zero]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    jz  0, execute_shr_b_store

execute_shr_b_zero:
    # If we are shifting by 0, SF ZF and PF are not affected
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_shr_b_done

execute_shr_b_eight:
    # If we are shifting by 8, zero the value and use fixed flags except for CF
    add bit_7, [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    eq  [flag_carry], 1, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val]

    jz  0, execute_shr_b_store

execute_shr_b_many:
    # If we are shifting by 9 or more bits, zero the value and use fixed flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 1, 0, [flag_parity]

    add 0, 0, [rb + val]

execute_shr_b_store:
    # Write the shifted value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_shr_b_done:
    arb 3
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; val, count, tmp
    # Function with multiple entry points

execute_sar_1_b:
    arb -3
    add 1, 0, [rb + count]
    jz  0, execute_sar_b

execute_sar_cl_b:
    arb -3
    add [reg_cl], 0, [rb + count]

execute_sar_b:
    add 0, 0, [flag_auxiliary_carry]

    # Read the value to shift
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # If we are shifting by 0, use a simplified algorithm
    jz  [rb + count], execute_sar_b_zero

    # Sign flag will remain unchanged
    lt  0x7f, [rb + val], [flag_sign]

    # If we are shifting more than 8 bits, use fixed values
    lt  [rb + count], 9, [rb + tmp]
    jz  [rb + tmp], execute_sar_b_many

    # If we are shifting by 8, use a simplified algorithm
    eq  [rb + count], 8, [rb + tmp]
    jnz [rb + tmp], execute_sar_b_eight

    # Carry flag is the last bit shifted out
    add [rb + count], -1, [rb + tmp]

    # Get tmp-th bit of val
    add bits, [rb + tmp], [ip + 1]
    add [0], [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    # Find shifted value in the shr table
    add shr, [rb + count], [ip + 1]
    add [0], [rb + val], [ip + 1]
    add [0], 0, [rb + val]

    # Sign-fill the left side of value
    add ones, [rb + count], [ip + 1]
    mul [0], [flag_sign], [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    # Update flags
    eq  [rb + val], 0, [flag_zero]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    # Overflow flag is always 0 because we never change the high order bit
    add 0, 0, [flag_overflow]

    jz  0, execute_sar_b_store

execute_sar_b_zero:
    # If we are shifting by 0, SF ZF and PF are not affected
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_sar_b_done

execute_sar_b_eight:
    # If we are shifting by 8, sign-fill the value and use fixed flags except for CF
    add bit_7, [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    add 0, 0, [flag_overflow]
    eq  [flag_sign], 0, [flag_zero]
    add 1, 0, [flag_parity]

    mul [flag_sign], 0xff, [rb + val]

    jz  0, execute_sar_b_store

execute_sar_b_many:
    # If we are shifting by 9 or more bits, sign-fill the value and use fixed flags
    add [flag_sign], 0, [flag_carry]
    add 0, 0, [flag_overflow]
    eq  [flag_sign], 0, [flag_zero]
    add 1, 0, [flag_parity]

    mul [flag_sign], 0xff, [rb + val]

execute_sar_b_store:
    # Write the shifted value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_sar_b_done:
    arb 3
    ret 2
.ENDFRAME

##########
ones:
    db  0b00000000, 0b10000000, 0b11000000, 0b11100000
    db  0b11110000, 0b11111000, 0b11111100, 0b11111110

.EOF
