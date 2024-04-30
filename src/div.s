.EXPORT execute_div_b
.EXPORT execute_div_w
.EXPORT divide

# From execute.s
.IMPORT exec_ip

# From interrupt.s
.IMPORT interrupt

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w

# From obj/bits.s
.IMPORT bits

# From state.s
.IMPORT reg_ip
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT reg_dl
.IMPORT reg_dh

# From util.s
.IMPORT split_16_8_8

##########
execute_div_b:
.FRAME loc_type, loc_addr; dvr, tmp
    arb -2

    # Read the divisor
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + dvr]

    # Raise #DE on division by zero
    jnz [rb + dvr], execute_div_b_non_zero

    add [exec_ip + 0], 0, [reg_ip + 0]
    add [exec_ip + 1], 0, [reg_ip + 1]

    add 0, 0, [rb - 1]
    arb -1
    call interrupt

    jz  0, execute_div_b_done

execute_div_b_non_zero:
    # Calculate the quotient and remainder
    add 2, 0, [rb - 1]
    add [reg_ah], 0, [rb - 4]
    add [reg_al], 0, [rb - 5]
    add [rb + dvr], 0, [rb - 6]
    arb -6
    call divide

    # Check if the quotient fits into a single byte
    lt  0xff, [rb - 8], [rb + tmp]
    jz  [rb + tmp], execute_div_b_quotient_ok

    # Raise #DE
    add [exec_ip + 0], 0, [reg_ip + 0]
    add [exec_ip + 1], 0, [reg_ip + 1]

    add 0, 0, [rb - 1]
    arb -1
    call interrupt

    jz  0, execute_div_b_done

execute_div_b_quotient_ok:
    add [rb - 8], 0, [reg_al]
    add [rb - 9], 0, [reg_ah]

execute_div_b_done:
    arb 2
    ret 2
.ENDFRAME

##########
execute_div_w:
.FRAME loc_type, loc_addr; dvr, res, mod, tmp
    arb -4

    # Read the divisor
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    mul [rb - 5], 0x100, [rb + dvr]
    add [rb - 4], [rb + dvr], [rb + dvr]

    # Raise #DE on division by zero
    jnz [rb + dvr], execute_div_w_non_zero

    add [exec_ip + 0], 0, [reg_ip + 0]
    add [exec_ip + 1], 0, [reg_ip + 1]

    add 0, 0, [rb - 1]
    arb -1
    call interrupt

    jz  0, execute_div_w_done

execute_div_w_non_zero:
    # Calculate the quotient and remainder
    add 4, 0, [rb - 1]
    add [reg_dh], 0, [rb - 2]
    add [reg_dl], 0, [rb - 3]
    add [reg_ah], 0, [rb - 4]
    add [reg_al], 0, [rb - 5]
    add [rb + dvr], 0, [rb - 6]
    arb -6
    call divide
    add [rb - 8], 0, [rb + res]
    add [rb - 9], 0, [rb + mod]

    # Check if the quotient fits into two bytes
    lt  0xffff, [rb + res], [rb + tmp]
    jz  [rb + tmp], execute_div_w_quotient_ok

    # Raise #DE
    add [exec_ip + 0], 0, [reg_ip + 0]
    add [exec_ip + 1], 0, [reg_ip + 1]

    add 0, 0, [rb - 1]
    arb -1
    call interrupt

    jz  0, execute_div_w_done

execute_div_w_quotient_ok:
    # Split the quotient and remainder into bytes
    add [rb + res], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_al]
    add [rb - 4], 0, [reg_ah]

    add [rb + mod], 0, [rb - 1]
    arb -1
    call split_16_8_8
    add [rb - 3], 0, [reg_dl]
    add [rb - 4], 0, [reg_dh]

execute_div_w_done:
    arb 4
    ret 2
.ENDFRAME

##########
divide:
.FRAME byte, dvd3, dvd2, dvd1, dvd0, dvr; res, mod, bit, dvd_bits, dvr_neg, tmp                    # returns res, mod
    arb -6

    add 0, 0, [rb + res]
    add 0, 0, [rb + mod]

    # Prepare a negative of the divisor for later
    mul [rb + dvr], -1, [rb + dvr_neg]

divide_byte_loop:
    add [rb + byte], -1, [rb + byte]

    # Convert byte-th byte of the dividend to bits
    add dvd0, [rb + byte], [ip + 1]
    mul [rb + 0], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + dvd_bits]

    add 8, 0, [rb + bit]

divide_bit_loop:
    add [rb + bit], -1, [rb + bit]

    # Move one additional bit from dvd to mod
    mul [rb + mod], 2, [rb + mod]
    add [rb + dvd_bits], [rb + bit], [ip + 1]
    add [0], [rb + mod], [rb + mod]

    # Make space for one additional bit in the result
    mul [rb + res], 2, [rb + res]

    # Anything larger than 16-bits will be a #DE, don't bother calculating it
    # Also, this avoids creating results that don't fit into a 32-bit signed int
    lt  0xffff, [rb + res], [rb + tmp]
    jnz [rb + tmp], divide_done

    # Does the divisor fit into mod?
    lt  [rb + mod], [rb + dvr], [rb + tmp]
    jnz [rb + tmp], divide_does_not_go_in

    # Divisor fits in mod, add a 1 to the result
    add [rb + res], 1, [rb + res]

    # Subtract divisor from mod
    add [rb + mod], [rb + dvr_neg], [rb + mod]

divide_does_not_go_in:
    # If this wasn't the last bit, loop
    jnz [rb + bit], divide_bit_loop

    # If this wasn't the last byte, loop
    jnz [rb + byte], divide_byte_loop

divide_done:
    arb 6
    ret 6
.ENDFRAME

.EOF
