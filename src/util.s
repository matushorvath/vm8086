.EXPORT check_range

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

.EOF
