.EXPORT check_range
.EXPORT split_16_8_8
.EXPORT split_20_8_12

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
split_16_8_8:
.FRAME vin; vlo, vhi, bit, pow, tmp                   # returns vlo, vhi
    arb -5

    add 0, 0, [rb + vhi]
    add [rb + vin], 0, [rb + vlo]

    add 8, 0, [rb + bit]

split_16_8_8_loop:
    add [rb + bit], -1, [rb + bit]

    # Load power of 2 for this high bit
    add split_16_8_8_pow_hi, [rb + bit], [ip + 1]
    add [0], 0, [rb + pow]

    # Is vlo smaller than pow?
    lt  [rb + vlo], [rb + pow], [rb + tmp]
    jnz [rb + tmp], split_16_8_8_zero

    # If vlo >= pow: subtract pow_hi from vlo, add pow_lo to vhi
    mul [rb + pow], -1, [rb + pow]
    add [rb + vlo], [rb + pow], [rb + vlo]

    add split_16_8_8_pow_lo, [rb + bit], [ip + 1]
    add [0], [rb + vhi], [rb + vhi]

split_16_8_8_zero:
    # Next bit
    jnz [rb + bit], split_16_8_8_loop

    arb 5
    ret 1

split_16_8_8_pow_lo:
    db  0x00000001, 0x00000002, 0x00000004, 0x00000008, 0x00000010, 0x00000020, 0x00000040, 0x00000080
split_16_8_8_pow_hi:
    db  0x00000100, 0x00000200, 0x00000400, 0x00000800, 0x00001000, 0x00002000, 0x00004000, 0x00008000
.ENDFRAME

##########
split_20_8_12:
.FRAME value; value_lo_12, value_hi_8, tmp                  # returns value_lo_12, value_hi_8
    arb -3

    add 0, 0, [rb + value_hi_8]
    add [rb + value], 0, [rb + value_lo_12]

    lt  0x7ffff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_19
    add [rb + value_lo_12], -0x80000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x80

split_20_8_14_bit_19:
    lt  0x3ffff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_18
    add [rb + value_lo_12], -0x40000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x40

split_20_8_14_bit_18:
    lt  0x1ffff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_17
    add [rb + value_lo_12], -0x20000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x20

split_20_8_14_bit_17:
    lt  0x0ffff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_16
    add [rb + value_lo_12], -0x10000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x10

split_20_8_14_bit_16:
    lt  0x07fff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_15
    add [rb + value_lo_12], -0x08000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x08

split_20_8_14_bit_15:
    lt  0x03fff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_14
    add [rb + value_lo_12], -0x04000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x04

split_20_8_14_bit_14:
    lt  0x01fff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_13
    add [rb + value_lo_12], -0x02000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x02

split_20_8_14_bit_13:
    lt  0x00fff, [rb + value], [rb + tmp]
    jz  [rb + tmp], split_20_8_14_bit_12
    add [rb + value_lo_12], -0x01000, [rb + value_lo_12]
    add [rb + value_hi_8], 0x01

split_20_8_14_bit_12:
    arb 3
    ret 1
.ENDFRAME

.EOF
