.EXPORT execute_aaa
.EXPORT execute_aas
.EXPORT execute_daa
.EXPORT execute_das
.EXPORT execute_aam
.EXPORT execute_aad

# From div.s
.IMPORT divide

# From execute.s
.IMPORT exec_ip

# From interrupt.s
.IMPORT interrupt

# From memory.s
.IMPORT read_cs_ip_b

# From obj/nibbles.s
.IMPORT nibbles

# From obj/parity.s
.IMPORT parity

# From state.s
.IMPORT inc_ip_b
.IMPORT reg_ip
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT flag_carry
.IMPORT flag_sign
.IMPORT flag_zero
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry

# From util.s
.IMPORT split_16_8_8

##########
execute_aaa:
.FRAME al_lo, tmp
    arb -2

    # Get the lower nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + al_lo]

    # Handle decimal carry if AF is set, or if AL > 9
    jnz [flag_auxiliary_carry], execute_aaa_decimal_carry
    lt  0x9, [rb + al_lo], [rb + tmp]
    jnz [rb + tmp], execute_aaa_decimal_carry

    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_carry]

    jz  0, execute_aaa_done

execute_aaa_decimal_carry:
    add [reg_al], 0x06, [reg_al]

    # There could be carry from AL
    lt  0xff, [reg_al], [rb + tmp]
    jz  [rb + tmp], execute_aaa_after_al
    add [reg_al], -0x100, [reg_al]

execute_aaa_after_al:
    add [reg_ah], 0x01, [reg_ah]

    # There could be carry from AH
    lt  0xff, [reg_ah], [rb + tmp]
    jz  [rb + tmp], execute_aaa_after_ah
    add [reg_ah], -0x100, [reg_ah]

execute_aaa_after_ah:
    add 1, 0, [flag_auxiliary_carry]
    add 1, 0, [flag_carry]

execute_aaa_done:
    # Clear the higher nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [reg_al]

    arb 2
    ret 0
.ENDFRAME

##########
execute_aas:
.FRAME al_lo, tmp
    arb -2

    # Get the lower nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + al_lo]

    # Handle decimal carry if AF is set, or if AL > 9
    jnz [flag_auxiliary_carry], execute_aas_decimal_carry
    lt  0x9, [rb + al_lo], [rb + tmp]
    jnz [rb + tmp], execute_aas_decimal_carry

    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_carry]

    jz  0, execute_aas_done

execute_aas_decimal_carry:
    add [reg_al], -0x06, [reg_al]

    # There could be borrow from AL
    lt  [reg_al], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_aas_after_al
    add [reg_al], 0x100, [reg_al]

execute_aas_after_al:
    add [reg_ah], -0x01, [reg_ah]

    # There could be borrow from AH
    lt  [reg_ah], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_aas_after_ah
    add [reg_ah], 0x100, [reg_ah]

execute_aas_after_ah:
    add 1, 0, [flag_auxiliary_carry]
    add 1, 0, [flag_carry]

execute_aas_done:
    # Clear the higher nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [reg_al]

    arb 2
    ret 0
.ENDFRAME

##########
execute_daa:
.FRAME al_lo, al, cf, tmp
    arb -4

    # Get the lower nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + al_lo]

    # Save AL and carry
    add [reg_al], 0, [rb + al]
    add [flag_carry], 0, [rb + cf]
    add 0, 0, [flag_carry]

    # Handle decimal carry for lower digit if AF is set, or if AL_lo > 9
    jnz [flag_auxiliary_carry], execute_daa_decimal_carry_lo
    lt  0x9, [rb + al_lo], [rb + tmp]
    jnz [rb + tmp], execute_daa_decimal_carry_lo

    add 0, 0, [flag_auxiliary_carry]
    jz  0, execute_daa_after_carry_lo

execute_daa_decimal_carry_lo:
    add [reg_al], 0x06, [reg_al]
    add [rb + cf], 0, [flag_carry]
    add 1, 0, [flag_auxiliary_carry]

    # Handle carry from AL
    lt  0xff, [reg_al], [rb + tmp]
    jz  [rb + tmp], execute_daa_after_carry_lo

    add [reg_al], -0x100, [reg_al]
    add 1, 0, [flag_carry]

execute_daa_after_carry_lo:
    # Handle decimal carry for higher digit if CF was set, or if saved AL > 0x99
    jnz [rb + cf], execute_daa_decimal_carry_hi
    lt  0x99, [rb + al], [rb + tmp]
    jnz [rb + tmp], execute_daa_decimal_carry_hi

    add 0, 0, [flag_carry]
    jz  0, execute_daa_after_carry_hi

execute_daa_decimal_carry_hi:
    add [reg_al], 0x60, [reg_al]
    add 1, 0, [flag_carry]

    # Handle carry from AL
    lt  0xff, [reg_al], [rb + tmp]
    jz  [rb + tmp], execute_daa_after_carry_hi

    add [reg_al], -0x100, [reg_al]

execute_daa_after_carry_hi:
    # Update flags
    lt  0x7f, [reg_al], [flag_sign]
    eq  [reg_al], 0, [flag_zero]

    add parity, [reg_al], [ip + 1]
    add [0], 0, [flag_parity]

    arb 4
    ret 0
.ENDFRAME

##########
execute_das:
.FRAME al_lo, al, cf, tmp
    arb -4

    # Get the lower nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + al_lo]

    # Save AL and carry
    add [reg_al], 0, [rb + al]
    add [flag_carry], 0, [rb + cf]
    add 0, 0, [flag_carry]

    # Handle decimal carry for lower digit if AF is set, or if AL_lo > 9
    jnz [flag_auxiliary_carry], execute_das_decimal_carry_lo
    lt  0x9, [rb + al_lo], [rb + tmp]
    jnz [rb + tmp], execute_das_decimal_carry_lo

    add 0, 0, [flag_auxiliary_carry]
    jz  0, execute_das_after_carry_lo

execute_das_decimal_carry_lo:
    add [reg_al], -0x06, [reg_al]
    add [rb + cf], 0, [flag_carry]
    add 1, 0, [flag_auxiliary_carry]

    # Handle borrow from AL
    lt  [reg_al], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_das_after_carry_lo

    add [reg_al], 0x100, [reg_al]
    add 1, 0, [flag_carry]

execute_das_after_carry_lo:
    # Handle decimal carry for higher digit if CF was set, or if saved AL > 0x99
    jnz [rb + cf], execute_das_decimal_carry_hi
    lt  0x99, [rb + al], [rb + tmp]
    jnz [rb + tmp], execute_das_decimal_carry_hi

    jz  0, execute_das_after_carry_hi

execute_das_decimal_carry_hi:
    add [reg_al], -0x60, [reg_al]
    add 1, 0, [flag_carry]

    # Handle borrow from AL
    lt  [reg_al], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_das_after_carry_hi

    add [reg_al], 0x100, [reg_al]

execute_das_after_carry_hi:
    # Update flags
    lt  0x7f, [reg_al], [flag_sign]
    eq  [reg_al], 0, [flag_zero]

    add parity, [reg_al], [ip + 1]
    add [0], 0, [flag_parity]

    arb 4
    ret 0
.ENDFRAME

##########
execute_aam:
.FRAME base
    arb -1

    # Read immediate value from the second byte
    call read_cs_ip_b
    add [rb - 2], 0, [rb + base]
    call inc_ip_b

    # Raise #DE on division by zero
    jnz [rb + base], execute_aam_non_zero

    add [exec_ip + 0], 0, [reg_ip + 0]
    add [exec_ip + 1], 0, [reg_ip + 1]

    add 0, 0, [rb - 1]
    arb -1
    call interrupt

    jz  0, execute_aam_done

execute_aam_non_zero:
    # Divide AL by the base
    add 1, 0, [rb - 1]
    add [reg_al], 0, [rb - 5]
    add [rb + base], 0, [rb - 6]
    arb -6
    call divide
    add [rb - 8], 0, [reg_ah]
    add [rb - 9], 0, [reg_al]

    # Update flags
    lt  0x7f, [reg_al], [flag_sign]
    eq  [reg_al], 0, [flag_zero]

    add parity, [reg_al], [ip + 1]
    add [0], 0, [flag_parity]

execute_aam_done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_aad:
.FRAME base, tmp
    arb -2

    # Read immediate value from the second byte
    call read_cs_ip_b
    add [rb - 2], 0, [rb + base]
    call inc_ip_b

    # Calculate new AL, take the lower byte of the result
    mul [reg_ah], [rb + base], [rb + tmp]
    add [reg_al], [rb + tmp], [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add 0, 0, [reg_ah]

    # Update flags
    lt  0x7f, [reg_al], [flag_sign]
    eq  [reg_al], 0, [flag_zero]

    add parity, [reg_al], [ip + 1]
    add [0], 0, [flag_parity]

    arb 2
    ret 0
.ENDFRAME

.EOF
