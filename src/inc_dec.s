.EXPORT execute_inc_w
#.EXPORT execute_dec_w

# From memory.s
.IMPORT read_w
.IMPORT write_w

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
.FRAME addr; value_lo, value_hi, tmp
execute_inc_w:
    arb -3

    # Read the value
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_w
    add [rb - 3], 0, [rb + value_lo]
    add [rb - 4], 0, [rb + value_hi]

    # Increment the value
    add [rb + value_lo], 1, [rb + value_lo]

    # Check for carry out of low byte
    lt  [rb + value_lo], 0x100, [rb + tmp]
    jz  [rb + tmp], execute_inc_w_after_carry

    add 0, 0, [rb + value_lo]
    add 1, [rb + value_hi], [rb + value_hi]

    # Check for carry out of high byte
    lt [rb + value_hi], 0x100, [rb + tmp]
    jz [rb + tmp], execute_inc_w_after_carry

    # Documentation says this does not update CF
    add 0, 0, [rb + value_hi]

execute_inc_w_after_carry:
    # Update flags
    lt  0x7f, [rb + value_hi], [flag_sign]

    add [rb + value_lo], [rb + value_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    # Parity of the low byte only, docs say
    add parity, [rb + value_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # If the low-order half-byte of result is 0x0, it must have been 0xf before
    mul [rb + value_lo], 2, [ip + 1]
    add [0], nibbles, [ip + 1]
    eq  [0], 0, [flag_auxiliary_carry]

    # If the high byte of result is 0x80, it must have been 0x7f before
    eq  [rb + value_hi], 0x80, [flag_overflow]              # TODO handle INTO

    # Write the result
    add [rb + addr], 0, [rb - 1]
    add [rb + value_lo], 0, [rb - 2]
    add [rb + value_hi], 0, [rb - 3]
    arb -3
    call write_w

    arb 3
    ret 1
.ENDFRAME

.EOF
