.EXPORT execute_rol_b
.EXPORT execute_rol_w
.EXPORT execute_ror_b
.EXPORT execute_ror_w
.EXPORT execute_rcl_b
.EXPORT execute_rcl_w
.EXPORT execute_rcr_b
.EXPORT execute_rcr_w
.EXPORT execute_shl_b
.EXPORT execute_shl_w
.EXPORT execute_shr_b
.EXPORT execute_shr_w
.EXPORT execute_sar_b
.EXPORT execute_sar_w

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

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

##########
execute_rol_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    add OP_AND, 0, [rb - 1]
    add [rb + loc_type_src], 0, [rb - 2]
    add [rb + loc_addr_src], 0, [rb - 3]
    add [rb + loc_type_dst], 0, [rb - 4]
    add [rb + loc_addr_dst], 0, [rb - 5]
    arb -5
    call execute_bitwise_b

    ret 4
.ENDFRAME

##########
execute_and_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    add OP_AND, 0, [rb - 1]
    add [rb + loc_type_src], 0, [rb - 2]
    add [rb + loc_addr_src], 0, [rb - 3]
    add [rb + loc_type_dst], 0, [rb - 4]
    add [rb + loc_addr_dst], 0, [rb - 5]
    arb -5
    call execute_bitwise_w

    ret 4
.ENDFRAME

##########
execute_or_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    add OP_OR, 0, [rb - 1]
    add [rb + loc_type_src], 0, [rb - 2]
    add [rb + loc_addr_src], 0, [rb - 3]
    add [rb + loc_type_dst], 0, [rb - 4]
    add [rb + loc_addr_dst], 0, [rb - 5]
    arb -5
    call execute_bitwise_b

    ret 4
.ENDFRAME

##########
execute_or_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst;
    add OP_OR, 0, [rb - 1]
    add [rb + loc_type_src], 0, [rb - 2]
    add [rb + loc_addr_src], 0, [rb - 3]
    add [rb + loc_type_dst], 0, [rb - 4]
    add [rb + loc_addr_dst], 0, [rb - 5]
    arb -5
    call execute_bitwise_w

    ret 4
.ENDFRAME

##########
execute_bitwise_b:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a, b, function, res, tmp
    arb -5

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

    # Determine which function to call
    add bitwise_table, [rb + op], [ip + 1]
    add [0], 0, [rb + function]

    # Calculate the result
    add [rb + a], 0, [rb - 1]
    add [rb + b], 0, [rb - 2]
    arb -2
    call [rb + function + 2]
    add [rb - 4], 0, [rb + res]

    # Update flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_auxiliary_carry]

    lt  0x7f, [rb + res], [flag_sign]
    eq  [rb + res], 0, [flag_zero]

    add parity, [rb + res], [ip + 1]
    add [0], 0, [flag_parity]

    # Write the destination value, unless this is the TEST instruction
    eq  [rb + op], OP_TEST, [rb + tmp]
    jnz [rb + tmp], execute_bitwise_b_end

    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

execute_bitwise_b_end:
    arb 5
    ret 5
.ENDFRAME

##########
execute_bitwise_w:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst; a_lo, a_hi, b_lo, b_hi, function, res_lo, res_hi, tmp
    arb -8

    # Read the source value
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + a_lo]
    add [rb - 5], 0, [rb + a_hi]

    # Read the destination value
    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + b_lo]
    add [rb - 5], 0, [rb + b_hi]

    # Determine which function to call
    add bitwise_table, [rb + op], [ip + 1]
    add [0], 0, [rb + function]

    # Calculate the result
    add [rb + a_lo], 0, [rb - 1]
    add [rb + b_lo], 0, [rb - 2]
    arb -2
    call [rb + function + 2]
    add [rb - 4], 0, [rb + res_lo]

    add [rb + a_hi], 0, [rb - 1]
    add [rb + b_hi], 0, [rb - 2]
    arb -2
    call [rb + function + 2]
    add [rb - 4], 0, [rb + res_hi]

    # Update flags
    add 0, 0, [flag_carry]
    add 0, 0, [flag_overflow]
    add 0, 0, [flag_auxiliary_carry]

    lt  0x7f, [rb + res_hi], [flag_sign]

    add [rb + res_lo], [rb + res_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + res_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Write the destination value, unless this is the TEST instruction
    eq  [rb + op], OP_TEST, [rb + tmp]
    jnz [rb + tmp], execute_bitwise_w_end

    add [rb + loc_type_dst], 0, [rb - 1]
    add [rb + loc_addr_dst], 0, [rb - 2]
    add [rb + res_lo], 0, [rb - 3]
    add [rb + res_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_bitwise_w_end:
    arb 8
    ret 5
.ENDFRAME

##########
and_b:
.FRAME a, b; res, bit, tmp, a_bits, b_bits                  # returns res
    arb -5

    # Convert operands to bits
    mul [rb + a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + b], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

and_b_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    eq  [rb + tmp], 2, [rb + tmp]                           # tmp is 2 means both bits are 1
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], and_b_loop

    arb 5
    ret 2
.ENDFRAME

##########
or_b:
.FRAME a, b; res, bit, tmp, a_bits, b_bits                  # returns res
    arb -5

    # Convert operands to bits
    mul [rb + a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + b], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

or_b_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    lt  0, [rb + tmp], [rb + tmp]                           # tmp is 0 means both bits are 0
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], or_b_loop

    arb 5
    ret 2
.ENDFRAME

##########
xor_b:
.FRAME a, b; res, bit, tmp, a_bits, b_bits                  # returns res
    arb -5

    # Convert operands to bits
    mul [rb + a], 8, [rb + a_bits]
    add bits, [rb + a_bits], [rb + a_bits]
    mul [rb + b], 8, [rb + b_bits]
    add bits, [rb + b_bits], [rb + b_bits]

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]

xor_b_loop:
    add [rb + bit], -1, [rb + bit]

    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + a_bits], [rb + bit], [ip + 5]
    add [rb + b_bits], [rb + bit], [ip + 2]
    eq  [0], [0], [rb + tmp]                                # if both bits are equal, tmp is 1
    eq  [rb + tmp], 0, [rb + tmp]                           # tmp = ~tmp
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    jnz [rb + bit], xor_b_loop

    arb 5
    ret 2
.ENDFRAME

##########
bitwise_table:
.SYMBOL OP_AND      0
    db  and_b
.SYMBOL OP_OR       1
    db  or_b
.SYMBOL OP_XOR      2
    db  xor_b
.SYMBOL OP_TEST     3
    db  and_b                           # TEST is the same as AND, but we skip writing the result

.EOF
