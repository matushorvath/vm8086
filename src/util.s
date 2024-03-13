.EXPORT check_range
.EXPORT mod

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
    jnz [rb + tmp], mod_negative_loop

mod_positive_loop:
    lt  [rb + value], [rb + divisor], [rb + tmp]
    jnz [rb + tmp], mod_done

    mul [rb + divisor], -1, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]
    jz  0, mod_positive_loop

mod_negative_loop:
    lt  [rb + value], 0, [rb + tmp]
    jz  [rb + tmp], mod_done

    add [rb + value], [rb + divisor], [rb + value]
    jz  0, mod_negative_loop

mod_done:
    add [rb + value], 0, [rb + tmp]

    arb 1
    ret 2
.ENDFRAME

.EOF
