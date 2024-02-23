.EXPORT incpc
.EXPORT check_8bit
.EXPORT check_16bit
.EXPORT mod_8bit
.EXPORT mod_16bit

# From error.s
.IMPORT report_error

# From state.s
.IMPORT reg_pc

##########
# Increase pc with wrap around
incpc:
.FRAME tmp
    arb -1

    add [reg_pc], 1, [reg_pc]

    eq  [reg_pc], 65536, [rb + tmp]
    jz  [rb + tmp], incpc_done

    add 0, 0, [reg_pc]

incpc_done:
    arb 1
    ret 0
.ENDFRAME

##########
# Halt if the parameter is not between 0 and 255
check_8bit:
.FRAME value; tmp
    arb -1

    lt  [rb + value], 0, [rb + tmp]
    jnz [rb + tmp], check_8bit_invalid
    lt  255, [rb + value], [rb + tmp]
    jnz [rb + tmp], check_8bit_invalid

    arb 1
    ret 1

check_8bit_invalid:
    add check_8bit_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

check_8bit_invalid_message:
    db  "invalid 8 bit value", 0
.ENDFRAME

##########
# Halt if the parameter is not between 0 and 65535
check_16bit:
.FRAME value; tmp
    arb -1

    lt  [rb + value], 0, [rb + tmp]
    jnz [rb + tmp], check_16bit_invalid
    lt  65535, [rb + value], [rb + tmp]
    jnz [rb + tmp], check_16bit_invalid

    arb 1
    ret 1

check_16bit_invalid:
    add check_16bit_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

check_16bit_invalid_message:
    db  "invalid 16 bit value", 0
.ENDFRAME

##########
# Calculate value mod 0x100
mod_8bit:
.FRAME value; tmp
    arb -2

    # Handle negative value
    lt  [rb + value], 0, [rb + tmp]
    jnz [rb + tmp], mod_8bit_negative_loop

mod_8bit_positive_loop:
    lt  [rb + value], 256, [rb + tmp]
    jnz [rb + tmp], mod_8bit_done

    add [rb + value], -256, [rb + value]
    jz  0, mod_8bit_positive_loop

mod_8bit_negative_loop:
    lt  [rb + value], 0, [rb + tmp]
    jz  [rb + tmp], mod_8bit_done

    add [rb + value], 256, [rb + value]
    jz  0, mod_8bit_negative_loop

mod_8bit_done:
    arb 2
    ret 1
.ENDFRAME

##########
# Calculate value mod 0x10000
mod_16bit:
.FRAME value; tmp
    arb -2

    # Handle negative value
    lt  [rb + value], 0, [rb + tmp]
    jnz [rb + tmp], mod_16bit_negative_loop

mod_16bit_positive_loop:
    lt  [rb + value], 65536, [rb + tmp]
    jnz [rb + tmp], mod_16bit_done

    add [rb + value], -65536, [rb + value]
    jz  0, mod_16bit_positive_loop

mod_16bit_negative_loop:
    lt  [rb + value], 0, [rb + tmp]
    jz  [rb + tmp], mod_16bit_done

    add [rb + value], 65536, [rb + value]
    jz  0, mod_16bit_negative_loop

mod_16bit_done:
    arb 2
    ret 1
.ENDFRAME

.EOF
