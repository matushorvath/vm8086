.EXPORT execute_neg_b
.EXPORT execute_neg_w

.EXPORT update_overflow

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From obj/nibbles.s
.IMPORT nibbles

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
execute_neg_b:
.FRAME lseg, loff; val, tmp
    arb -2

    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # Negate the value
    jz  [rb + val], execute_neg_b_zero
    mul [rb + val], -1, [rb + val]
    add 0x100, [rb + val], [rb + val]

execute_neg_b_zero:
    # Update flags
    lt  0x7f, [rb + val], [flag_sign]
    eq  [rb + val], 0, [flag_zero]
    eq  [flag_zero], 0, [flag_carry]
    eq  [rb + val], 0x80, [flag_overflow]

    add parity, [rb + val], [ip + 1]
    add [0], 0, [flag_parity]

    # Set auxiliary carry flag if low-order half-byte of val != 0
    mul [rb + val], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + tmp]

    eq  [rb + tmp], 0, [flag_auxiliary_carry]
    eq  [flag_auxiliary_carry], 0, [flag_auxiliary_carry]

    # Write the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 2
    ret 2
.ENDFRAME

##########
execute_neg_w:
.FRAME lseg, loff; val_lo, val_hi, tmp
    arb -3

    # Read the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val_lo]
    add [rb - 5], 0, [rb + val_hi]

    # Negate the value
    jz  [rb + val_lo], execute_neg_b_zero_lo
    mul [rb + val_lo], -1, [rb + val_lo]
    add 0x100, [rb + val_lo], [rb + val_lo]
    add [rb + val_hi], 1, [rb + val_hi]                     # calculating (0 - N), so there's always carry from lo to hi

execute_neg_b_zero_lo:
    jz  [rb + val_hi], execute_neg_b_zero_hi
    mul [rb + val_hi], -1, [rb + val_hi]
    add 0x100, [rb + val_hi], [rb + val_hi]

execute_neg_b_zero_hi:
    # Update flags
    lt  0x7f, [rb + val_hi], [flag_sign]
    add [rb + val_lo], [rb + val_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]
    eq  [flag_zero], 0, [flag_carry]

    # Set overflow flag if val == 0x8000
    eq  [rb + val_hi], 0x80, [flag_overflow]
    eq  [rb + val_lo], 0x00, [rb + tmp]
    add [flag_overflow], [rb + tmp], [flag_overflow]
    eq  [flag_overflow], 2, [flag_overflow]

    add parity, [rb + val_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Set auxiliary carry flag if low-order half-byte of val != 0
    mul [rb + val_lo], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + tmp]

    eq  [rb + tmp], 0, [flag_auxiliary_carry]
    eq  [flag_auxiliary_carry], 0, [flag_auxiliary_carry]

    # Write the value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 3
    ret 2
.ENDFRAME

##########
update_overflow:
.FRAME a, b, res; tmp
    arb -1

    lt  0x7f, [rb + a], [rb + a]
    lt  0x7f, [rb + b], [rb + b]
    lt  0x7f, [rb + res], [rb + res]

    eq  [rb + a], [rb + b], [rb + tmp]
    jnz [rb + tmp], update_overflow_same_sign

    # When operands are different signs, overflow is always false
    add 0, 0, [flag_overflow]
    jz  0, update_overflow_done

update_overflow_same_sign:
    # When operands are the same sign but different than the result, overflow is true
    eq  [rb + a], [rb + res], [rb + tmp]
    eq  [rb + tmp], 0, [flag_overflow]

update_overflow_done:
    arb 1
    ret 3
.ENDFRAME

.EOF
