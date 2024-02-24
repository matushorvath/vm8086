.EXPORT incpc
.EXPORT check_8bit
.EXPORT check_16bit
.EXPORT mod_8bit
.EXPORT mod_16bit
.EXPORT split_16_8_8

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
# Calculate value mod 0x100, should only be used if the input is close to output
mod_8bit:
.FRAME value; tmp                                   # returns tmp
    arb -1

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
    add [rb + value], 0, [rb + tmp]

    arb 1
    ret 1
.ENDFRAME

##########
# Calculate value mod 0x10000, should only be used if the input is close to output
mod_16bit:
.FRAME value; tmp                                   # returns tmp
    arb -1

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
    add [rb + value], 0, [rb + tmp]

    arb 1
    ret 1
.ENDFRAME

##########
split_16_8_8:
.FRAME v16; v8h, v8l, bit, pow, tmp                 # returns v8h, v8l
    arb -5

    add 0, 0, [rb + v8h]
    add [rb + v16], 0, [rb + v8l]

    add 7, 0, [rb + bit]

split_16_8_8_loop:
    # Load power of 2 for this high bit
    add split_16_8_8_pow_hi, [rb + bit], [ip + 1]
    add [0], 0, [rb + pow]

    # Is v8l smaller than pow?
    lt  [rb + v8l], [rb + pow], [rb + tmp]
    jnz [rb + tmp], split_16_8_8_zero

    # If v8l >= pow: subtract pow_hi from v8l, add pow_lo to v8h
    mul [rb + pow], -1, [rb + pow]
    add [rb + v8l], [rb + pow], [rb + v8l]

    add split_16_8_8_pow_lo, [rb + bit], [ip + 1]
    add [0], 0, [rb + pow]
    add [rb + v8h], [rb + pow], [rb + v8h]

split_16_8_8_zero:
    # Next bit
    add [rb + bit], -1, [rb + bit]
    jnz [rb + bit], split_16_8_8_loop

    arb 5
    ret 1

split_16_8_8_pow_lo:
    db  1, 2, 4, 8, 16, 32, 64, 128
split_16_8_8_pow_hi:
    db  256, 512, 1024, 2048, 4096, 8192, 16384, 32768
.ENDFRAME

.EOF
