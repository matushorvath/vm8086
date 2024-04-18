.EXPORT execute_mul_b
.EXPORT execute_mul_w
.EXPORT execute_imul_b
.EXPORT execute_imul_w

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
.FRAME loc_type, loc_addr; op1
    arb -1

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + op1]

    # Calculate the result and split it into AL and AH
    mul [rb + op1], [reg_al], [rb - 1]
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
execute_imul_b:
.FRAME loc_type, loc_addr; op1, op2, res, tmp
    arb -4

    # Read the operands
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_b

    add [rb - 4], 0, [rb + op1]
    add [reg_al], 0, [rb + op2]

    # Convert both operands to native intcode signed numbers
    lt  [rb + op1], 0x80, [rb + tmp]
    jnz [rb + tmp], execute_imul_b_op1_signed
    add [rb + op1], -0x100, [rb + op1]

execute_imul_b_op1_signed:
    lt  [rb + op2], 0x80, [rb + tmp]
    jnz [rb + tmp], execute_imul_b_op2_signed
    add [rb + op2], -0x100, [rb + op2]

execute_imul_b_op2_signed:
    # Calculate the result and convert it back to two's complement
    mul [rb + op1], [rb + op2], [rb + res]

    lt  [rb + res], 0, [rb + tmp]
    jz  [rb + tmp], execute_imul_b_res_tc
    add [rb + res], 0x10000, [rb + res]

execute_imul_b_res_tc:
    # Split the result into AL and AH
    add [rb + res], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    # Update flags
    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 0, 0, [flag_zero]

    # Carry and overflow are false if upper half of the result contains no significant bits,
    # i.e. the upper half and the most significant bit of the lower half are all either 0 or 1,
    # i.e. res is between 0x0000 and 0x007f or between 0xff80 and 0xffff.
    lt  [rb + res], 0x0080, [flag_carry]
    lt  0xff7f, [rb + res], [rb + tmp]
    add [flag_carry], [rb + tmp], [flag_carry]
    eq  [flag_carry], 0, [flag_carry]
    add [flag_carry], 0, [flag_overflow]

    arb 4
    ret 2
.ENDFRAME

##########
execute_mul_w:
.FRAME loc_type, loc_addr; op1_lo, op1_hi, op2_lo, op2_hi, tmp
    arb -5

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + op1_lo]
    add [rb - 5], 0, [rb + op1_hi]

    # Save AL and AH, since we will overwrite them with the result
    add [reg_al], 0, [rb + op2_lo]
    add [reg_ah], 0, [rb + op2_hi]

    # Calculate the result byte by byte
    # This avoids problems with intcode implementations that use signed 32-bit ints
    mul [rb + op1_lo], [rb + op2_lo], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    mul [rb + op1_lo], [rb + op2_hi], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_ah], [reg_ah]
    add [rb - 4], 0, [reg_dl]

    mul [rb + op1_hi], [rb + op2_lo], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_ah], [reg_ah]
    add [rb - 4], [reg_dl], [reg_dl]

    mul [rb + op1_hi], [rb + op2_hi], [rb - 1]
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

##########
execute_imul_w:
.FRAME loc_type, loc_addr; op1_lo, op1_hi, op2_lo, op2_hi, sign, tmp
    arb -6

    # Read the operands
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w

    add [rb - 4], 0, [rb + op1_lo]
    add [rb - 5], 0, [rb + op1_hi]
    add [reg_al], 0, [rb + op2_lo]
    add [reg_ah], 0, [rb + op2_hi]

    add 0, 0, [rb + sign]

    # Convert both operands to positive numbers, remembering how many signs we flip
    lt  [rb + op1_hi], 0x80, [rb + tmp]
    jnz [rb + tmp], execute_imul_w_op1_positive_hi
    eq  [rb + sign], 0, [rb + sign]

    jz  [rb + op1_lo], execute_imul_w_op1_positive_lo
    mul [rb + op1_lo], -1, [rb + op1_lo]
    add 0x100, [rb + op1_lo], [rb + op1_lo]
    add [rb + op1_hi], 1, [rb + op1_hi]

execute_imul_w_op1_positive_lo:
    jz  [rb + op1_hi], execute_imul_w_op1_positive_hi
    mul [rb + op1_hi], -1, [rb + op1_hi]
    add 0x100, [rb + op1_hi], [rb + op1_hi]

execute_imul_w_op1_positive_hi:
    lt  [rb + op2_hi], 0x80, [rb + tmp]
    jnz [rb + tmp], execute_imul_w_op2_positive_hi
    eq  [rb + sign], 0, [rb + sign]

    jz  [rb + op2_lo], execute_imul_w_op2_positive_lo
    mul [rb + op2_lo], -1, [rb + op2_lo]
    add 0x100, [rb + op2_lo], [rb + op2_lo]
    add [rb + op2_hi], 1, [rb + op2_hi]

execute_imul_w_op2_positive_lo:
    jz  [rb + op2_hi], execute_imul_w_op2_positive_hi
    mul [rb + op2_hi], -1, [rb + op2_hi]
    add 0x100, [rb + op2_hi], [rb + op2_hi]

execute_imul_w_op2_positive_hi:
    # Calculate the result byte by byte
    # This avoids problems with intcode implementations that use signed 32-bit ints
    mul [rb + op1_lo], [rb + op2_lo], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    mul [rb + op1_lo], [rb + op2_hi], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_ah], [reg_ah]
    add [rb - 4], 0, [reg_dl]

    mul [rb + op1_hi], [rb + op2_lo], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_ah], [reg_ah]
    add [rb - 4], [reg_dl], [reg_dl]

    mul [rb + op1_hi], [rb + op2_hi], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], [reg_dl], [reg_dl]
    add [rb - 4], 0, [reg_dh]

    # Handle carry from the add operations
    lt  [reg_ah], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_imul_w_after_ah_carry_1
    add [reg_ah], -0x100, [reg_ah]
    add [reg_dl], 1, [reg_dl]

execute_imul_w_after_ah_carry_1:
    lt  [reg_ah], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_imul_w_after_ah_carry_2
    add [reg_ah], -0x100, [reg_ah]
    add [reg_dl], 1, [reg_dl]

execute_imul_w_after_ah_carry_2:
    lt  [reg_dl], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_imul_w_after_dl_carry
    add [reg_dl], -0x100, [reg_dl]
    add [reg_dh], 1, [reg_dh]

execute_imul_w_after_dl_carry:
    # Negate the result based on the sign we calculated in the beginning
    jz  [rb + sign], execute_imul_w_res_positive_dh

    jz  [reg_al], execute_imul_w_res_positive_al
    mul [reg_al], -1, [reg_al]
    add 0x100, [reg_al], [reg_al]
    add [reg_ah], 1, [reg_ah]

execute_imul_w_res_positive_al:
    jz  [reg_ah], execute_imul_w_res_positive_ah
    mul [reg_ah], -1, [reg_ah]
    add 0x100, [reg_ah], [reg_ah]
    add [reg_dl], 1, [reg_dl]

execute_imul_w_res_positive_ah:
    jz  [reg_dl], execute_imul_w_res_positive_dl
    mul [reg_dl], -1, [reg_dl]
    add 0x100, [reg_dl], [reg_dl]
    add [reg_dh], 1, [reg_dh]

execute_imul_w_res_positive_dl:
    jz  [reg_dh], execute_imul_w_res_positive_dh
    mul [reg_dh], -1, [reg_dh]
    add 0x100, [reg_dh], [reg_dh]

execute_imul_w_res_positive_dh:
    # Update flags
    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 0, 0, [flag_zero]

    # Carry and overflow are false if upper half of the result contains no significant bits,
    # i.e. the upper half and the most significant bit of the lower half are all either 0 or 1,
    # i.e. res is between 0x00000000 and 0x00007fff or between 0xffff8000 and 0xffffffff.
    mul [reg_dh], 0x100, [rb + tmp]
    add [reg_dl], [rb + tmp], [rb + tmp]
    mul [rb + tmp], 0x100, [rb + tmp]
    add [reg_ah], [rb + tmp], [rb + tmp]

    lt  [rb + tmp], 0x000080, [flag_carry]
    lt  0xffff7f, [rb + tmp], [rb + tmp]
    add [flag_carry], [rb + tmp], [flag_carry]
    eq  [flag_carry], 0, [flag_carry]
    add [flag_carry], 0, [flag_overflow]

    arb 6
    ret 2
.ENDFRAME

.EOF
