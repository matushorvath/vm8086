.EXPORT check_range

.EXPORT split_32_16_16
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
.FRAME vin; vlo, vhi, bits, bit, pow, tmp                   # returns vlo, vhi
    # Function with multiple entry points

    # TODO We actually need split_32_8_8_8_8 for MUL/IMUL
split_32_16_16:
    arb -6
    add 16, 0, [rb + bits]
    jz  0, split_hi_lo

split_16_8_8:
    arb -6
    add 8, 0, [rb + bits]

split_hi_lo:
    add 0, 0, [rb + vhi]
    add [rb + vin], 0, [rb + vlo]

    add [rb + bits], 0, [rb + bit]

split_hi_lo_loop:
    add [rb + bit], -1, [rb + bit]

    # Load power of 2 for this high bit
    add split_hi_lo_pow, [rb + bits], [rb + tmp]
    add [rb + tmp], [rb + bit], [ip + 1]
    add [0], 0, [rb + pow]

    # Is vlo smaller than pow?
    lt  [rb + vlo], [rb + pow], [rb + tmp]
    jnz [rb + tmp], split_hi_lo_zero

    # If vlo >= pow: subtract pow_hi from vlo, add pow_lo to vhi
    mul [rb + pow], -1, [rb + pow]
    add [rb + vlo], [rb + pow], [rb + vlo]

    add split_hi_lo_pow, [rb + bit], [ip + 1]
    add [0], [rb + vhi], [rb + vhi]

split_hi_lo_zero:
    # Next bit
    jnz [rb + bit], split_hi_lo_loop

    arb 6
    ret 1

split_hi_lo_pow:
    db  0x00000001, 0x00000002, 0x00000004, 0x00000008, 0x00000010, 0x00000020, 0x00000040, 0x00000080
    db  0x00000100, 0x00000200, 0x00000400, 0x00000800, 0x00001000, 0x00002000, 0x00004000, 0x00008000
# TODO these will crash the C IC VM (but work with JS IC VM)
# most likely related to the 32-bit integer size used; try to write the mul and split algorithms without large numbers
#    db  0x00010000, 0x00020000, 0x00040000, 0x00080000, 0x00100000, 0x00200000, 0x00400000, 0x00800000
#    db  0x01000000, 0x02000000, 0x04000000, 0x08000000, 0x10000000, 0x20000000, 0x40000000, 0x80000000
.ENDFRAME

.EOF
