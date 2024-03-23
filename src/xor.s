# TODO .EXPORT execute_and
# TODO .EXPORT execute_bit
.EXPORT execute_xor_b
# TODO .EXPORT execute_xor_w
# TODO .EXPORT execute_ora

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b

# From obj/bits.s
.IMPORT bits

# From obj/parity.s
.IMPORT parity

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# TODO remove this comment
# AND OR XOR TEST affect flags
#   OF AND CF always clear
#   AF undefined
#   SF ZF PF reflect the result
# NOT has no effect on flags

# TODO HW do logical operations calculate PF from the whole result, or just lower byte? docs say whole result

##########
execute_xor_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a, b, res
    arb -3

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + a]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + b]

    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    arb -2
    call xor_b
    add [rb - 4], 0, [rb + res]

    # Update flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_auxiliary_carry]

    lt  0x7f, [rb + res], [flag_sign]
    eq  [rb + res], 0, [flag_zero]

    add parity, [rb + res], [ip + 1]
    add [0], 0, [flag_parity]

    # Write the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 3
    ret 4
.ENDFRAME

##########
xor_b:
.FRAME a, b; res, tmp, a_bits, b_bits, bit
    arb -5

    # Find source value bits
    mul [rb + a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]

    # Find destination value bits
    mul [rb + b], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

execute_xor_b_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    eq  [0], [0], [rb + tmp]                                # if both bits are equal, tmp is 1
    eq  [rb + tmp], 0, [rb + tmp]                           # tmp = ~tmp
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], execute_xor_b_loop

    arb 5
    ret 2
.ENDFRAME

.EOF

# TODO XOR MEM, IMMED
# 0x80 <immed> REG8/MEM8, IMMED8
# 0x81 <immed> REG16/MEM16, IMMED16
