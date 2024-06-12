.EXPORT execute_sub_b
.EXPORT execute_sub_w

.EXPORT execute_sbb_b
.EXPORT execute_sbb_w

.EXPORT execute_cmp_b
.EXPORT execute_cmp_w

# From arithmetic.s
.IMPORT update_overflow

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From util/nibbles.s
.IMPORT nibbles

# From util/parity.s
.IMPORT parity

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

##########
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; src, dst, store, res, tmp
    # Function with multiple entry points

execute_sub_b:
    arb -5
    add 0, 0, [flag_carry]
    add 1, 0, [rb + store]
    jz  0, execute_subtract_b

execute_sbb_b:
    arb -5
    add 1, 0, [rb + store]
    jz  0, execute_subtract_b

execute_cmp_b:
    arb -5
    add 0, 0, [flag_carry]
    add 0, 0, [rb + store]

execute_subtract_b:
    # Read the source value
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + src]

    # Read the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + dst]

    # Update flag_auxiliary_carry before we modify flag_carry
    add [rb + src], 0, [rb - 1]
    add [rb + dst], 0, [rb - 2]
    arb -2
    call update_auxiliary_carry_sbb

    # Calculate the result
    mul [rb + src], -1, [rb + tmp]
    add [rb + dst], [rb + tmp], [rb + res]
    mul [flag_carry], -1, [rb + tmp]
    add [rb + res], [rb + tmp], [rb + res]

    # Check for carry
    lt  [rb + res], 0x00, [flag_carry]
    jz  [flag_carry], execute_subtract_b_after_carry

    add [rb + res], 0x100, [rb + res]

execute_subtract_b_after_carry:
    # Update flags
    lt  0x7f, [rb + res], [flag_sign]
    eq  [rb + res], 0, [flag_zero]

    add parity, [rb + res], [ip + 1]
    add [0], 0, [flag_parity]

    # Update flag_overflow
    add [rb + res], 0, [rb - 1]
    add [rb + src], 0, [rb - 2]
    add [rb + dst], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value if requested
    jz  [rb + store], execute_subtract_b_end

    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

execute_subtract_b_end:
    arb 5
    ret 4
.ENDFRAME

##########
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; src_lo, src_hi, dst_lo, dst_hi, store, res_lo, res_hi, tmp
    # Function with multiple entry points

execute_sub_w:
    arb -8
    add 0, 0, [flag_carry]
    add 1, 0, [rb + store]
    jz  0, execute_subtract_w

execute_sbb_w:
    arb -8
    add 1, 0, [rb + store]
    jz  0, execute_subtract_w

execute_cmp_w:
    arb -8
    add 0, 0, [flag_carry]
    add 0, 0, [rb + store]

execute_subtract_w:
    # Read the source value
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + src_lo]
    add [rb - 5], 0, [rb + src_hi]

    # Read the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + dst_lo]
    add [rb - 5], 0, [rb + dst_hi]

    # Update flag_auxiliary_carry before we modify flag_carry
    add [rb + src_lo], 0, [rb - 1]
    add [rb + dst_lo], 0, [rb - 2]
    arb -2
    call update_auxiliary_carry_sbb

    # Calculate the result
    mul [rb + src_lo], -1, [rb + tmp]
    add [rb + dst_lo], [rb + tmp], [rb + res_lo]
    mul [flag_carry], -1, [rb + tmp]
    add [rb + res_lo], [rb + tmp], [rb + res_lo]
    mul [rb + src_hi], -1, [rb + tmp]
    add [rb + dst_hi], [rb + tmp], [rb + res_hi]

    # Check for carry out of low byte
    lt  [rb + res_lo], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_subtract_w_after_carry_lo

    add [rb + res_lo], 0x100, [rb + res_lo]
    add [rb + res_hi], -1, [rb + res_hi]

execute_subtract_w_after_carry_lo:
    # Check for carry out of high byte
    lt  [rb + res_hi], 0x00, [flag_carry]
    jz  [flag_carry], execute_subtract_w_after_carry_hi

    add [rb + res_hi], 0x100, [rb + res_hi]

execute_subtract_w_after_carry_hi:
    # Update flags
    lt  0x7f, [rb + res_hi], [flag_sign]

    add [rb + res_lo], [rb + res_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + res_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Update flag_overflow
    add [rb + res_hi], 0, [rb - 1]
    add [rb + src_hi], 0, [rb - 2]
    add [rb + dst_hi], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value if requested
    jz  [rb + store], execute_subtract_w_end

    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + res_lo], 0, [rb - 3]
    add [rb + res_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_subtract_w_end:
    arb 8
    ret 4
.ENDFRAME

##########
update_auxiliary_carry_sbb:
.FRAME src, dst; a4l, b4l, tmp, res
    arb -4

    # Find low-order half-byte of src and dst
    mul [rb + src], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + a4l]

    mul [rb + dst], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + b4l]

    # Subtract b4l - a4l - carry
    mul [rb + a4l], -1, [rb + tmp]
    add [rb + b4l], [rb + tmp], [rb + res]
    mul [flag_carry], -1, [rb + tmp]
    add [rb + res], [rb + tmp], [rb + res]

    # Set auxiliary carry flag if sum < 0x0
    lt  [rb + res], 0x0, [flag_auxiliary_carry]

    arb 4
    ret 2
.ENDFRAME

.EOF
