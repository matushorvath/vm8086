.EXPORT execute_inc_b
.EXPORT execute_inc_w
.EXPORT execute_dec_b
.EXPORT execute_dec_w

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w
.IMPORT write_location_b
.IMPORT write_location_w

# From obj/nibbles.s
.IMPORT nibbles

# From obj/parity.s
.IMPORT parity

# From state.s
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

##########
execute_inc_b:
.FRAME lseg, loff; value, tmp
    arb -2

    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + value]

    # Increment the value
    add [rb + value], 1, [rb + value]

    # Check for carry
    lt  [rb + value], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_inc_b_after_carry

    # Documentation says this does not update CF
    add [rb + value], -0x100, [rb + value]

execute_inc_b_after_carry:
    # Update flags
    lt  0x7f, [rb + value], [flag_sign]
    eq  [rb + value], 0, [flag_zero]

    # Parity flag
    add parity, [rb + value], [ip + 1]
    add [0], 0, [flag_parity]

    # If the low-order half-byte of result is 0x0, it must have been 0xf before
    mul [rb + value], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    eq  [0], 0, [flag_auxiliary_carry]

    # If the result is 0x80, it must have been 0x7f before
    eq  [rb + value], 0x80, [flag_overflow]

    # Write the result
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 2
    ret 2
.ENDFRAME

##########
execute_inc_w:
.FRAME lseg, loff; value_lo, value_hi, tmp
    arb -3

    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
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

    # If the result is 0x8000, it must have been 0x7fff before
    eq  [rb + value_hi], 0x80, [flag_overflow]
    eq  [rb + value_lo], 0x00, [rb + tmp]
    add [flag_overflow], [rb + tmp], [rb + tmp]
    eq  [rb + tmp], 2, [flag_overflow]

    # Write the result
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 3
    ret 2
.ENDFRAME

##########
execute_dec_b:
.FRAME lseg, loff; value, tmp
    arb -2

    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + value]

    # Decrement the value
    add [rb + value], -1, [rb + value]

    # Check for borrow
    lt  [rb + value], 0, [rb + tmp]
    jz  [rb + tmp], execute_dec_b_after_borrow

    # Documentation says this does not update CF
    add [rb + value], 0x100, [rb + value]

execute_dec_b_after_borrow:
    # Update flags
    lt  0x7f, [rb + value], [flag_sign]
    eq  [rb + value], 0, [flag_zero]

    # Parity flag
    add parity, [rb + value], [ip + 1]
    add [0], 0, [flag_parity]

    # If the low-order half-byte of result is 0xf, it must have been 0x0 before
    mul [rb + value], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    eq  [0], 0xf, [flag_auxiliary_carry]

    # If the result is 0x7f, it must have been 0x80 before
    eq  [rb + value], 0x7f, [flag_overflow]

    # Write the result
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 2
    ret 2
.ENDFRAME

##########
execute_dec_w:
.FRAME lseg, loff; value_lo, value_hi, tmp
    arb -3

    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
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

    # If the result is 0x8000, it must have been 0x7fff before
    eq  [rb + value_hi], 0x7f, [flag_overflow]
    eq  [rb + value_lo], 0xff, [rb + tmp]
    add [flag_overflow], [rb + tmp], [rb + tmp]
    eq  [rb + tmp], 2, [flag_overflow]

    # Write the result
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 3
    ret 2
.ENDFRAME

.EOF
