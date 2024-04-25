.EXPORT divide_b

# From obj/bits.s
.IMPORT bits

##########
divide_b:
.FRAME dvd, dvr; res, mod, bit, dvd_bits, dvr_neg, tmp                     # returns res, mod
    arb -6

    add 0, 0, [rb + res]
    add 0, 0, [rb + mod]
    add 0, 0, [rb + bit]

    # Convert the dividend to bits
    mul [rb + dvd], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + dvd_bits]

    # Prepare a negative of the divisor for later
    mul [rb + dvr], -1, [rb + dvr_neg]

divide_b_loop:
    # Move one additional bit from dvd to mod
    mul [rb + mod], 2, [rb + mod]
    add [rb + dvd_bits], [rb + bit], [ip + 1]
    add [0], [rb + mod], [rb + mod]

    # Make space for one additional bit in the result
    mul [rb + res], 2, [rb + res]

    # Does the divisor fit into mod?
    lt  [rb + mod], [rb + dvr], [rb + tmp]
    jnz [rb + tmp], divide_b_does_not_go_in

    # Divisor fits in mod, add a 1 to the result
    add [rb + res], 1, [rb + res]

    # Subtract divisor from mod
    add [rb + mod], [rb + dvr_neg], [rb + mod]

divide_b_does_not_go_in:
    # If this wasn't the last bit, loop
    add [rb + bit], 1, [rb + bit]
    eq  [rb + bit], 8, [rb + tmp]
    jz  [rb + tmp], divide_b_loop

    arb 6
    ret 2
.ENDFRAME

.EOF
