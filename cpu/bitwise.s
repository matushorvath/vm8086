.EXPORT execute_and_b
.EXPORT execute_and_w
.EXPORT execute_or_b
.EXPORT execute_or_w
.EXPORT execute_xor_b
.EXPORT execute_xor_w
.EXPORT execute_test_b
.EXPORT execute_test_w
.EXPORT execute_not_b
.EXPORT execute_not_w

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# From util/bits.s
.IMPORT bit_7

# From util/parity.s
.IMPORT parity

##########
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; a, b, function, store, res, tmp
    # Function with multiple entry points

execute_and_b:
    arb -6
    add and_b, 0, [rb + function]
    add 1, 0, [rb + store]
    jz  0, execute_bitwise_b

execute_or_b:
    arb -6
    add or_b, 0, [rb + function]
    add 1, 0, [rb + store]
    jz  0, execute_bitwise_b

execute_xor_b:
    arb -6
    add xor_b, 0, [rb + function]
    add 1, 0, [rb + store]
    jz  0, execute_bitwise_b

execute_test_b:
    arb -6
    add and_b, 0, [rb + function]
    add 0, 0, [rb + store]

execute_bitwise_b:
    # Read the source value
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + a]

    # Read the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + b]

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

    # Write the destination value if requested
    jz  [rb + store], .done

    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

.done:
    arb 6
    ret 4
.ENDFRAME

##########
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; a_lo, a_hi, b_lo, b_hi, function, store, res_lo, res_hi, tmp
    # Function with multiple entry points

execute_and_w:
    arb -9
    add and_b, 0, [rb + function]
    add 1, 0, [rb + store]
    jz  0, execute_bitwise_w

execute_or_w:
    arb -9
    add or_b, 0, [rb + function]
    add 1, 0, [rb + store]
    jz  0, execute_bitwise_w

execute_xor_w:
    arb -9
    add xor_b, 0, [rb + function]
    add 1, 0, [rb + store]
    jz  0, execute_bitwise_w

execute_test_w:
    arb -9
    add and_b, 0, [rb + function]
    add 0, 0, [rb + store]

execute_bitwise_w:
    # Read the source value
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + a_lo]
    add [rb - 5], 0, [rb + a_hi]

    # Read the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + b_lo]
    add [rb - 5], 0, [rb + b_hi]

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

    # Write the destination value if requested
    jz  [rb + store], .done

    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + res_lo], 0, [rb - 3]
    add [rb + res_hi], 0, [rb - 4]
    arb -4
    call write_location_w

.done:
    arb 9
    ret 4
.ENDFRAME

##########
and_b:
.FRAME a, b; res, bit, tmp, table                           # returns res
    arb -4

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]
    add bit_7, 0, [rb + table]

.loop:
    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + table], [rb + a], [ip + 5]
    add [rb + table], [rb + b], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    eq  [rb + tmp], 2, [rb + tmp]                           # tmp is 2 means both bits are 1
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    add [rb + bit], -1, [rb + bit]
    add [rb + table], -0x100, [rb + table]

    jnz [rb + bit], .loop

    arb 4
    ret 2
.ENDFRAME

##########
or_b:
.FRAME a, b; res, bit, tmp, table                           # returns res
    arb -4

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]
    add bit_7, 0, [rb + table]

.loop:
    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + table], [rb + a], [ip + 5]
    add [rb + table], [rb + b], [ip + 2]
    add [0], [0], [rb + tmp]                                # bit n of a + bit n of b -> tmp

    lt  0, [rb + tmp], [rb + tmp]                           # tmp is 0 means both bits are 0
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    add [rb + bit], -1, [rb + bit]
    add [rb + table], -0x100, [rb + table]

    jnz [rb + bit], .loop

    arb 4
    ret 2
.ENDFRAME

##########
xor_b:
.FRAME a, b; res, bit, tmp, table                           # returns res
    arb -4

    # Process individual bits and build the output
    add 0, 0, [rb + res]
    add 8, 0, [rb + bit]
    add bit_7, 0, [rb + table]

.loop:
    mul [rb + res], 2, [rb + res]                           # res << 1

    add [rb + table], [rb + a], [ip + 5]
    add [rb + table], [rb + b], [ip + 2]
    eq  [0], [0], [rb + tmp]                                # if both bits are equal, tmp is 1

    eq  [rb + tmp], 0, [rb + tmp]                           # tmp = ~tmp
    add [rb + res], [rb + tmp], [rb + res]                  # res += bit n

    add [rb + bit], -1, [rb + bit]
    add [rb + table], -0x100, [rb + table]

    jnz [rb + bit], .loop

    arb 4
    ret 2
.ENDFRAME

##########
execute_not_b:
.FRAME lseg, loff;
    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b

    # Negate the value
    mul [rb - 4], -1, [rb - 4]
    add 0xff, [rb - 4], [rb - 3]        # ~read_location_b() -> param 3

    # Write the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -3
    call write_location_b

    ret 2
.ENDFRAME

##########
execute_not_w:
.FRAME lseg, loff;
    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w

    # Negate both bytes of the value
    mul [rb - 4], -1, [rb - 4]
    add 0xff, [rb - 4], [rb - 3]        # ~read_location_w().lo -> param 3
    mul [rb - 5], -1, [rb - 5]
    add 0xff, [rb - 5], [rb - 4]        # ~read_location_w().lo -> param 4

    # Write the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -4
    call write_location_w

    ret 2
.ENDFRAME

.EOF
