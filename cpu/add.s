.EXPORT execute_add_b
.EXPORT execute_add_w

.EXPORT execute_adc_b
.EXPORT execute_adc_w

# From arithmetic.s
.IMPORT update_overflow

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From util/nibbles.s
.IMPORT nibble_0

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
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; src, dst, res, tmp
    # Function with multiple entry points

execute_add_b:
    # Clear the carry flag when performing add without carry
    add 0, 0, [flag_carry]

execute_adc_b:
    arb -4

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
    call update_auxiliary_carry_adc

    # Calculate the result
    add [rb + src], [rb + dst], [rb + res]
    add [rb + res], [flag_carry], [rb + res]

    # Check for carry
    lt  0xff, [rb + res], [flag_carry]
    jz  [flag_carry], .after_carry

    add [rb + res], -0x100, [rb + res]

.after_carry:
    # Update flags
    lt  0x7f, [rb + res], [flag_sign]
    eq  [rb + res], 0, [flag_zero]

    add parity, [rb + res], [ip + 1]
    add [0], 0, [flag_parity]

    # Update flag_overflow
    add [rb + src], 0, [rb - 1]
    add [rb + dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + res], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 4
    ret 4
.ENDFRAME

##########
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; src_lo, src_hi, dst_lo, dst_hi, res_lo, res_hi, tmp
    # Function with multiple entry points

execute_add_w:
    # Clear the carry flag when performing add without carry
    add 0, 0, [flag_carry]

execute_adc_w:
    arb -7

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
    call update_auxiliary_carry_adc

    # Calculate the result
    add [rb + src_lo], [rb + dst_lo], [rb + res_lo]
    add [rb + res_lo], [flag_carry], [rb + res_lo]
    add [rb + src_hi], [rb + dst_hi], [rb + res_hi]

    # Check for carry out of low byte
    lt  0xff, [rb + res_lo], [rb + tmp]
    jz  [rb + tmp], .after_carry_lo

    add [rb + res_lo], -0x100, [rb + res_lo]
    add [rb + res_hi], 1, [rb + res_hi]

.after_carry_lo:
    # Check for carry out of high byte
    lt  0xff, [rb + res_hi], [flag_carry]
    jz  [flag_carry], .after_carry_hi

    add [rb + res_hi], -0x100, [rb + res_hi]

.after_carry_hi:
    # Update flags
    lt  0x7f, [rb + res_hi], [flag_sign]

    add [rb + res_lo], [rb + res_hi], [rb + tmp]
    eq  [rb + tmp], 0, [flag_zero]

    add parity, [rb + res_lo], [ip + 1]
    add [0], 0, [flag_parity]

    # Update flag_overflow
    add [rb + src_hi], 0, [rb - 1]
    add [rb + dst_hi], 0, [rb - 2]
    add [rb + res_hi], 0, [rb - 3]
    arb -3
    call update_overflow

    # Write the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + res_lo], 0, [rb - 3]
    add [rb + res_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 7
    ret 4
.ENDFRAME

##########
update_auxiliary_carry_adc:
.FRAME src, dst; a4l, b4l, tmp
    arb -3

    # Find low-order half-byte of src and dst
    add nibble_0, [rb + src], [ip + 1]
    add [0], 0, [rb + a4l]

    add nibble_0, [rb + dst], [ip + 1]
    add [0], 0, [rb + b4l]

    # Sum a4l, b4l and carry
    add [rb + a4l], [rb + b4l], [rb + tmp]
    add [flag_carry], [rb + tmp], [rb + tmp]

    # Set auxiliary carry flag if sum > 0xf
    lt  0xf, [rb + tmp], [flag_auxiliary_carry]

    arb 3
    ret 2
.ENDFRAME

.EOF
