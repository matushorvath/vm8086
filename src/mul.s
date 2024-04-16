.EXPORT execute_mul_b
.EXPORT execute_mul_w

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From state.s
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT reg_dl
.IMPORT reg_dh

.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# From util.s
.IMPORT split_16_8_8

##########
execute_mul_b:
.FRAME loc_type, loc_addr; val
    arb -1

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # Calculate the result and split it into AL and AH
    mul [rb + val], [reg_al], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    # Update flags
    eq  [reg_ah], 0, [flag_carry]
    eq  [flag_carry], 0, [flag_carry]
    add [flag_carry], 0, [flag_overflow]

    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 0, 0, [flag_zero]

    arb 1
    ret 2
.ENDFRAME

##########
execute_mul_w:
.FRAME loc_type, loc_addr; val_lo, val_hi, val_al, val_ah, tmp
    arb -5

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val_lo]
    add [rb - 5], 0, [rb + val_hi]

    # Save AL and AH, since we will overwrite them with the result
    add [reg_al], 0, [rb + val_al]
    add [reg_ah], 0, [rb + val_ah]

    # Calculate the result byte by byte
    # This avoids problems with intcode implementations that use signed 32-bit ints
    mul [rb + val_lo], [rb + val_al], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    mul [rb + val_lo], [rb + val_ah], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_ah], [reg_ah]
    add [rb - 4], 0, [reg_dl]

    mul [rb + val_hi], [rb + val_al], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_ah], [reg_ah]
    add [rb - 4], [reg_dl], [reg_dl]

    mul [rb + val_hi], [rb + val_ah], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_dl], [reg_dl]
    add [rb - 4], 0, [reg_dh]

    # Handle carry from the add operations
    lt  [reg_ah], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_mul_w_after_ah_carry_1
    add [reg_ah], -0x100, [reg_ah]
    add [reg_dl], 1, [reg_dl]

execute_mul_w_after_ah_carry_1:
    lt  [reg_ah], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_mul_w_after_ah_carry_2
    add [reg_ah], -0x100, [reg_ah]
    add [reg_dl], 1, [reg_dl]

execute_mul_w_after_ah_carry_2:
    lt  [reg_dl], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_mul_w_after_dl_carry
    add [reg_dl], -0x100, [reg_dl]
    add [reg_dh], 1, [reg_dh]

execute_mul_w_after_dl_carry:
    # Update flags
    add [reg_dl], [reg_dh], [flag_carry]
    lt  0, [flag_carry], [flag_carry]
    add [flag_carry], 0, [flag_overflow]

    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 0, 0, [flag_zero]

    arb 5
    ret 2
.ENDFRAME

.EOF
