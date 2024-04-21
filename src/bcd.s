.EXPORT execute_aaa
.EXPORT execute_aas
.EXPORT execute_daa
.EXPORT execute_das

# From obj/nibbles.s
.IMPORT nibbles

# From state.s
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT flag_carry
.IMPORT flag_auxiliary_carry

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
    add [reg_ah], 0x01, [reg_ah]

    # There could be carry from AL to AH
    lt  0xff, [reg_al], [rb + tmp]
    jz  [rb + tmp], execute_aaa_after_al_carry
    add [reg_al], -0x100, [reg_al]
    add [reg_ah], 1, [reg_ah]

execute_aaa_after_al_carry:
    # There could be carry from AH
    lt  0xff, [reg_ah], [rb + tmp]
    jz  [rb + tmp], execute_aaa_after_ah_carry
    add [reg_ah], -0x100, [reg_ah]

execute_aaa_after_ah_carry:
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
    add [reg_ah], -0x01, [reg_ah]

    # There could be borrow from AL to AH
    lt  [reg_al], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_aas_after_al_carry
    add [reg_al], 0x100, [reg_al]
    add [reg_ah], -1, [reg_ah]

execute_aas_after_al_carry:
    # There could be borrow from AH
    lt  [reg_ah], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_aas_after_ah_carry
    add [reg_ah], 0x100, [reg_ah]

execute_aas_after_ah_carry:
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
    arb 4
    ret 0
.ENDFRAME

.EOF
