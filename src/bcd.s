.EXPORT execute_aaa

# From obj/nibbles.s
.IMPORT nibbles

# From state.s
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT flag_carry
.IMPORT flag_auxiliary_carry

##########
execute_aaa:
.FRAME digit, tmp
    arb -2

    # Get the higher nibble of AL
    mul [reg_al], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + digit]

    # Handle decimal carry if AF is set, or if AL > 9
    jnz [flag_auxiliary_carry], execute_aaa_decimal_carry
    lt  9, [rb + digit], [rb + tmp]
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

.EOF
