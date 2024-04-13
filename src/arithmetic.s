.EXPORT update_overflow

# From state.s
.IMPORT flag_overflow

##########
update_overflow:
.FRAME a, b, res; tmp
    arb -1

    lt  0x7f, [rb + a], [rb + a]
    lt  0x7f, [rb + b], [rb + b]
    lt  0x7f, [rb + res], [rb + res]

    eq  [rb + a], [rb + b], [rb + tmp]
    jnz [rb + tmp], update_overflow_same_sign

    # When operands are different signs, overflow is always false
    add 0, 0, [flag_overflow]
    jz  0, update_overflow_done

update_overflow_same_sign:
    # When operands are the same sign but different than the result, overflow is true
    eq  [rb + a], [rb + res], [rb + tmp]
    eq  [rb + tmp], 0, [flag_overflow]

update_overflow_done:
    arb 1
    ret 3
.ENDFRAME

.EOF
