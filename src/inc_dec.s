.EXPORT execute_inc_w
.EXPORT execute_dec_w

# From location.s
.IMPORT read_location_w
.IMPORT write_location_w

# From nibbles.s
.IMPORT nibbles

# From parity.s
.IMPORT parity

# From state.s
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

##########
execute_inc_w:
.FRAME loc_type, loc_addr; value_lo, value_hi, tmp
    arb -3

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    # Increment the value
    add [rb + value_lo], 1, [rb + value_lo]

    # Check for carry out of low byte
    lt  [rb + value_lo], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_inc_w_after_carry

    add [rb + value_lo], -0x100, [rb + value_lo]
    add [rb + value_hi], 1, [rb + value_hi]

    # Check for carry out of high byte
    lt  [rb + value_hi], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_inc_w_after_carry

    # Documentation says this does not update CF
    add [rb + value_hi], -0x100, [rb + value_hi]

execute_inc_w_after_carry:
    # Update flags
    lt  0x7f, [rb + value_hi], [flag_sign]

    add [rb + value_lo], [rb + value_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    # Parity of the low byte only, docs say
    add parity, [rb + value_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # If the low-order half-byte of result is 0x0, it must have been 0xf before
    mul [rb + value_lo], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    eq  [0], 0, [flag_auxiliary_carry]

    # If the high byte of result is 0x80, it must have been 0x7f before
    eq  [rb + value_hi], 0x80, [flag_overflow]

    # Write the result
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 3
    ret 2
.ENDFRAME

##########
execute_dec_w:
.FRAME loc_type, loc_addr; value_lo, value_hi, tmp
    arb -3

    # Read the value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    # Decrement the value
    add [rb + value_lo], -1, [rb + value_lo]

    # Check for borrow into low byte
    lt  [rb + value_lo], 0, [rb + tmp]
    jz  [rb + tmp], execute_dec_w_after_borrow

    add [rb + value_lo], 0x100, [rb + value_lo]
    add [rb + value_hi], -1, [rb + value_hi]

    # Check for borrow into high byte
    lt  [rb + value_hi], 0, [rb + tmp]
    jz  [rb + tmp], execute_dec_w_after_borrow

    # Documentation says this does not update CF
    add [rb + value_hi], 0x100, [rb + value_hi]

execute_dec_w_after_borrow:
    # Update flags
    lt  0x7f, [rb + value_hi], [flag_sign]

    add [rb + value_lo], [rb + value_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    # Parity of the low byte only, docs say
    add parity, [rb + value_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # If the low-order half-byte of result is 0xf, it must have been 0x0 before
    mul [rb + value_lo], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    eq  [0], 0xf, [flag_auxiliary_carry]

    # If the high byte of result is 0x7f, it must have been 0x80 before
    eq  [rb + value_hi], 0x7f, [flag_overflow]

    # Write the result
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 3
    ret 2
.ENDFRAME

.EOF
