.EXPORT check_range
.EXPORT mod

# TODO .EXPORT split_16_8_8
# TODO .EXPORT split_8_4_4

# From error.s
.IMPORT report_error

##########
# Halt if not 0 <= value <= range
check_range:
.FRAME value, range; tmp
    arb -1

    lt  [rb + value], 0, [rb + tmp]
    jnz [rb + tmp], check_range_invalid
    lt  [rb + range], [rb + value], [rb + tmp]
    jnz [rb + tmp], check_range_invalid

    arb 1
    ret 2

check_range_invalid:
    add check_range_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

check_range_invalid_message:
    db  "value out of range", 0
.ENDFRAME

##########
# Calculate value mod divisor; should only be used if value/divisor is a small number
mod:
.FRAME value, divisor; tmp                                   # returns tmp
    arb -1

    # Handle negative value
    lt  [rb + value], 0, [rb + tmp]
    jnz [rb + tmp], mod_8bit_negative_loop

mod_8bit_positive_loop:
    lt  [rb + value], [rb + divisor], [rb + tmp]
    jnz [rb + tmp], mod_8bit_done

    mul [rb + divisor], -1, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]
    jz  0, mod_8bit_positive_loop

mod_8bit_negative_loop:
    lt  [rb + value], 0, [rb + tmp]
    jz  [rb + tmp], mod_8bit_done

    add [rb + value], [rb + divisor], [rb + value]
    jz  0, mod_8bit_negative_loop

mod_8bit_done:
    add [rb + value], 0, [rb + tmp]

    arb 1
    ret 2
.ENDFRAME

##########
split_8_4_4:
.FRAME v8; v4h, v4l                                 # returns v4h, v4l
    arb -2

    add [rb + v8], 0, [rb - 1]
    add 4, 0, [rb - 2]
    arb -2
    call split_hi_lo

    add [rb - 4], 0, [rb + v4h]
    add [rb - 5], 0, [rb + v4l]

    arb 2
    ret 1
.ENDFRAME

##########
split_16_8_8:
.FRAME v16; v8h, v8l                                # returns v8h, v8l
    arb -2

    add [rb + v16], 0, [rb - 1]
    add 8, 0, [rb - 2]
    arb -2
    call split_hi_lo

    add [rb - 4], 0, [rb + v8h]
    add [rb - 5], 0, [rb + v8l]

    arb 2
    ret 1
.ENDFRAME

##########
split_hi_lo:
.FRAME vin, bits; vh, vl, bit, pow, tmp             # returns vh, vl
    arb -5

    add 0, 0, [rb + vh]
    add [rb + vin], 0, [rb + vl]

    add 8, 0, [rb + bit]

split_hi_lo_loop:
    add [rb + bit], -1, [rb + bit]

    # Load power of 2 for this high bit
    add split_hi_lo_pow, [rb + bits], [rb + tmp]
    add [rb + tmp], [rb + bit], [ip + 1]
    add [0], 0, [rb + pow]

    # Is vl smaller than pow?
    lt  [rb + vl], [rb + pow], [rb + tmp]
    jnz [rb + tmp], split_hi_lo_zero

    # If vl >= pow: subtract pow_hi from vl, add pow_lo to vh
    mul [rb + pow], -1, [rb + pow]
    add [rb + vl], [rb + pow], [rb + vl]

    add split_hi_lo_pow, [rb + bit], [ip + 1]
    add [0], 0, [rb + pow]
    add [rb + vh], [rb + pow], [rb + vh]

split_hi_lo_zero:
    # Next bit
    jnz [rb + bit], split_hi_lo_loop

    arb 5
    ret 2

split_hi_lo_pow:
    db  1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768
.ENDFRAME

.EOF
