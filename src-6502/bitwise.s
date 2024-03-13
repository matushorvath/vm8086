.EXPORT execute_and
.EXPORT execute_bit
.EXPORT execute_eor
.EXPORT execute_ora

# From obj/bits.s
.IMPORT bits

# From memory.s
.IMPORT read
.IMPORT write

# From state.s
.IMPORT flag_negative
.IMPORT flag_overflow
.IMPORT flag_zero
.IMPORT reg_a

##########
execute_and:
.FRAME addr; tmp, a_bits, b_bits, bit, res
    arb -5

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + tmp]

    # Find both reg_a and tmp in bits
    mul [reg_a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + tmp], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

execute_and_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    eq  [rb + tmp], 2, [rb + tmp]                           # tmp is 2 means both bits are 1
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], execute_and_loop

    # Save the value
    add [rb + res], 0, [reg_a]

    # Update flags
    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 5
    ret 1
.ENDFRAME

##########
execute_eor:
.FRAME addr; tmp, a_bits, b_bits, bit, res
    arb -5

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + tmp]

    # Find both reg_a and tmp in bits
    mul [reg_a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + tmp], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

execute_eor_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    eq  [0], [0], [rb + tmp]                                # if both bits are equal, tmp is 1
    eq  [rb + tmp], 0, [rb + tmp]                           # tmp = ~tmp
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], execute_eor_loop

    # Save the value
    add [rb + res], 0, [reg_a]

    # Update flags
    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 5
    ret 1
.ENDFRAME

##########
execute_ora:
.FRAME addr; tmp, a_bits, b_bits, bit, res
    arb -5

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + tmp]

    # Find both reg_a and tmp in bits
    mul [reg_a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + tmp], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

execute_ora_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    lt  0, [rb + tmp], [rb + tmp]                           # tmp is 0 means both bits are 0
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], execute_ora_loop

    # Save the value
    add [rb + res], 0, [reg_a]

    # Update flags
    lt  0x7f, [reg_a], [flag_negative]
    eq  [reg_a], 0, [flag_zero]

    arb 5
    ret 1
.ENDFRAME

##########
execute_bit:
.FRAME addr; tmp, a_bits, b_bits, bit
    arb -4

    # Read the second operand
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + tmp]

    # Find both reg_a and tmp in bits
    mul [reg_a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + tmp], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [flag_zero]
    add 8, 0, [rb + bit]

execute_bit_loop:
    add [rb + bit], -1, [rb + bit]

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    eq  [rb + tmp], 2, [rb + tmp]                           # tmp is 2 means both bits are 1
    jnz [rb + tmp], execute_bit_not_zero                    # at least one non-zero bit, skip setting flag_zero to 1

    jnz [rb + bit], execute_bit_loop

    add 1, 0, [flag_zero]                                   # all bits of reg_a & [addr] are zero

execute_bit_not_zero:
    # Set flag_negative to bit 7
    add [rb + b_bits], 7, [ip + 1]
    add [0], 0, [flag_negative]

    # Set flag_overflow to bit 6
    add [rb + b_bits], 6, [ip + 1]
    add [0], 0, [flag_overflow]

    arb 4
    ret 1
.ENDFRAME

.EOF
