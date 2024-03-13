.EXPORT execute_inc_w
#.EXPORT execute_dec_w

# From memory.s
.IMPORT read_w
.IMPORT write_w

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

    add 0, 0, [flag_auxiliary_carry]
    add 0, 0, [flag_overflow]

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
    jz  [rb + tmp], execute_inc_w_after_carry_overflow

    add 1, 0, [flag_auxiliary_carry]
    add 0, 0, [rb + value_lo]
    add 1, [rb + value_hi], [rb + value_hi]

    # Check for overflow (carry out of high byte)
    lt [rb + value_hi], 0x100, [rb + tmp]
    jz [rb + tmp], execute_inc_w_after_carry_overflow

    add 1, 0, [flag_overflow]                       # TODO handle INTO
    add 0, 0, [rb + value_hi]

execute_inc_w_after_carry_overflow:
    # Update other flags
    lt  0x7f, [rb + value_hi], [flag_sign]

    add [rb + value_lo], [rb + value_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + value_lo], [ip + 1]
    eq  [0], 0, [flag_parity]
    add parity, [rb + value_hi], [ip + 1]
    eq  [0], [flag_parity], [flag_parity]

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

##########
.FRAME addr; delta
execute_inc_w:
    arb -1
    add 1, 0, [rb + delta]

    jz 0, execute_inc_dec_w

execute_dec_w:
    arb -1
    add -1, 0, [rb + delta]

execute_inc_dec_w:
    add [rb + addr], 0, [rb - 1]
    arb -1
    call read

    add [rb - 3], [rb + delta], [rb - 1]            # read() + delta -> param0
    add 0x10000, 0, [rb - 2]
    arb -2
    call mod

    # If lower 

    # TODO AF OF PF

    lt  0x7f, [rb - 4], [flag_sign]
    eq  [rb - 4], 0, [flag_zero]

    add [rb + addr], 0, [rb - 1]
    add [rb - 4], 0, [rb - 2]                       # mod() -> param1
    arb -2
    call write

    arb 1
    ret 1
.ENDFRAME

.EOF
