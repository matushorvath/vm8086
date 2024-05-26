.EXPORT check_range
.EXPORT split_16_8_8

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
.FRAME vin; vlo, vhi, tmp                                   # returns vlo, vhi
    arb -3

    add 0, 0, [rb + vhi]
    add [rb + vin], 0, [rb + vlo]

    lt  0x7fff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_15
    add [rb + vlo], -0x8000, [rb + vlo]
    add [rb + vhi], 0x80, [rb + vhi]

split_16_8_8_bit_15:
    lt  0x3fff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_14
    add [rb + vlo], -0x4000, [rb + vlo]
    add [rb + vhi], 0x40, [rb + vhi]

split_16_8_8_bit_14:
    lt  0x1fff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_13
    add [rb + vlo], -0x2000, [rb + vlo]
    add [rb + vhi], 0x20, [rb + vhi]

split_16_8_8_bit_13:
    lt  0x0fff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_12
    add [rb + vlo], -0x1000, [rb + vlo]
    add [rb + vhi], 0x10, [rb + vhi]

split_16_8_8_bit_12:
    lt  0x07ff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_11
    add [rb + vlo], -0x0800, [rb + vlo]
    add [rb + vhi], 0x08, [rb + vhi]

split_16_8_8_bit_11:
    lt  0x03ff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_10
    add [rb + vlo], -0x0400, [rb + vlo]
    add [rb + vhi], 0x04, [rb + vhi]

split_16_8_8_bit_10:
    lt  0x01ff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_09
    add [rb + vlo], -0x0200, [rb + vlo]
    add [rb + vhi], 0x02, [rb + vhi]

split_16_8_8_bit_09:
    lt  0x00ff, [rb + vlo], [rb + tmp]
    jz  [rb + tmp], split_16_8_8_bit_08
    add [rb + vlo], -0x0100, [rb + vlo]
    add [rb + vhi], 0x01, [rb + vhi]

split_16_8_8_bit_08:
    arb 3
    ret 1
.ENDFRAME

.EOF
