.EXPORT execute_rol_1_w
.EXPORT execute_rol_cl_w
.EXPORT execute_ror_1_w
.EXPORT execute_ror_cl_w
.EXPORT execute_rcl_1_w
.EXPORT execute_rcl_cl_w
.EXPORT execute_rcr_1_w
.EXPORT execute_rcr_cl_w

# From location.s
.IMPORT read_location_w
.IMPORT write_location_w

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_1
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5
.IMPORT bit_6
.IMPORT bit_7

# From util/mod17.s
.IMPORT mod17

# From util/nibbles.s
.IMPORT nibble_0

# From util/shl.s
.IMPORT shl_0
.IMPORT shl_1
.IMPORT shl_2
.IMPORT shl_3
.IMPORT shl_4
.IMPORT shl_5
.IMPORT shl_6
.IMPORT shl_7

# From util/shr.s
.IMPORT shr_0
.IMPORT shr_1
.IMPORT shr_2
.IMPORT shr_3
.IMPORT shr_4
.IMPORT shr_5
.IMPORT shr_6
.IMPORT shr_7

# From state.s
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_overflow

##########
.FRAME lseg, loff; input_lo, input_hi, output_lo, output_hi, count
    # Function with multiple entry points

execute_rol_1_w:
    arb -5
    add 1, 0, [rb + count]
    jz  0, execute_rol_w

execute_rol_cl_w:
    arb -5
    add [reg_cl], 0, [rb + count]

execute_rol_w:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], .done

    # Use the nibbles table to obtain count mod 16
    add nibble_0, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + input_lo]
    add [rb - 5], 0, [rb + input_hi]

    # Jump to the label that handles this case
    add .table, [rb + count], [ip + 2]
    jz  0, [0]

.table:
    db .by_0
    db .by_1
    db .by_2
    db .by_3
    db .by_4
    db .by_5
    db .by_6
    db .by_7
    db .by_8
    db .by_9
    db .by_a
    db .by_b
    db .by_c
    db .by_d
    db .by_e
    db .by_f

.by_0:
    add [rb + input_lo], 0, [rb + output_lo]
    add [rb + input_hi], 0, [rb + output_hi]

    jz  0, .flags

.by_1:
    add shr_7, [rb + input_hi], [ip + 5]
    add shl_1, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_7, [rb + input_lo], [ip + 5]
    add shl_1, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_2:
    add shr_6, [rb + input_hi], [ip + 5]
    add shl_2, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_6, [rb + input_lo], [ip + 5]
    add shl_2, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_3:
    add shr_5, [rb + input_hi], [ip + 5]
    add shl_3, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_5, [rb + input_lo], [ip + 5]
    add shl_3, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_4:
    add shr_4, [rb + input_hi], [ip + 5]
    add shl_4, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_4, [rb + input_lo], [ip + 5]
    add shl_4, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_5:
    add shr_3, [rb + input_hi], [ip + 5]
    add shl_5, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_3, [rb + input_lo], [ip + 5]
    add shl_5, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_6:
    add shr_2, [rb + input_hi], [ip + 5]
    add shl_6, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_2, [rb + input_lo], [ip + 5]
    add shl_6, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_7:
    add shr_1, [rb + input_hi], [ip + 5]
    add shl_7, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_1, [rb + input_lo], [ip + 5]
    add shl_7, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_8:
    add [rb + input_lo], 0, [rb + output_hi]
    add [rb + input_hi], 0, [rb + output_lo]

    jz  0, .flags

.by_9:
    add shr_7, [rb + input_hi], [ip + 5]
    add shl_1, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_7, [rb + input_lo], [ip + 5]
    add shl_1, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_a:
    add shr_6, [rb + input_hi], [ip + 5]
    add shl_2, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_6, [rb + input_lo], [ip + 5]
    add shl_2, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_b:
    add shr_5, [rb + input_hi], [ip + 5]
    add shl_3, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_5, [rb + input_lo], [ip + 5]
    add shl_3, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_c:
    add shr_4, [rb + input_hi], [ip + 5]
    add shl_4, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_4, [rb + input_lo], [ip + 5]
    add shl_4, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_d:
    add shr_3, [rb + input_hi], [ip + 5]
    add shl_5, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_3, [rb + input_lo], [ip + 5]
    add shl_5, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_e:
    add shr_2, [rb + input_hi], [ip + 5]
    add shl_6, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_2, [rb + input_lo], [ip + 5]
    add shl_6, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_f:
    add shr_1, [rb + input_hi], [ip + 5]
    add shl_7, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_1, [rb + input_lo], [ip + 5]
    add shl_7, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

.flags:
    # Update flags
    add bit_0, [rb + output_lo], [ip + 1]
    add [0], 0, [flag_carry]

    add bit_7, [rb + output_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + output_lo], 0, [rb - 3]
    add [rb + output_hi], 0, [rb - 4]
    arb -4
    call write_location_w

.done:
    arb 5
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; input_lo, input_hi, output_lo, output_hi, count
    # Function with multiple entry points

execute_ror_1_w:
    arb -5
    add 1, 0, [rb + count]
    jz  0, execute_ror_w

execute_ror_cl_w:
    arb -5
    add [reg_cl], 0, [rb + count]

execute_ror_w:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], .done

    # Use the nibbles table to obtain count mod 16
    add nibble_0, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + input_lo]
    add [rb - 5], 0, [rb + input_hi]

    # Jump to the label that handles this case
    add .table, [rb + count], [ip + 2]
    jz  0, [0]

.table:
    db .by_0
    db .by_1
    db .by_2
    db .by_3
    db .by_4
    db .by_5
    db .by_6
    db .by_7
    db .by_8
    db .by_9
    db .by_a
    db .by_b
    db .by_c
    db .by_d
    db .by_e
    db .by_f

.by_0:
    add [rb + input_lo], 0, [rb + output_lo]
    add [rb + input_hi], 0, [rb + output_hi]

    jz  0, .flags

.by_1:
    add shl_7, [rb + input_lo], [ip + 5]
    add shr_1, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_7, [rb + input_hi], [ip + 5]
    add shr_1, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_2:
    add shl_6, [rb + input_lo], [ip + 5]
    add shr_2, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_6, [rb + input_hi], [ip + 5]
    add shr_2, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_3:
    add shl_5, [rb + input_lo], [ip + 5]
    add shr_3, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_5, [rb + input_hi], [ip + 5]
    add shr_3, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_4:
    add shl_4, [rb + input_lo], [ip + 5]
    add shr_4, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_4, [rb + input_hi], [ip + 5]
    add shr_4, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_5:
    add shl_3, [rb + input_lo], [ip + 5]
    add shr_5, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_3, [rb + input_hi], [ip + 5]
    add shr_5, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_6:
    add shl_2, [rb + input_lo], [ip + 5]
    add shr_6, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_2, [rb + input_hi], [ip + 5]
    add shr_6, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_7:
    add shl_1, [rb + input_lo], [ip + 5]
    add shr_7, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_1, [rb + input_hi], [ip + 5]
    add shr_7, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    jz  0, .flags

.by_8:
    add [rb + input_hi], 0, [rb + output_lo]
    add [rb + input_lo], 0, [rb + output_hi]

    jz  0, .flags

.by_9:
    add shl_7, [rb + input_lo], [ip + 5]
    add shr_1, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_7, [rb + input_hi], [ip + 5]
    add shr_1, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_a:
    add shl_6, [rb + input_lo], [ip + 5]
    add shr_2, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_6, [rb + input_hi], [ip + 5]
    add shr_2, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_b:
    add shl_5, [rb + input_lo], [ip + 5]
    add shr_3, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_5, [rb + input_hi], [ip + 5]
    add shr_3, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_c:
    add shl_4, [rb + input_lo], [ip + 5]
    add shr_4, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_4, [rb + input_hi], [ip + 5]
    add shr_4, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_d:
    add shl_3, [rb + input_lo], [ip + 5]
    add shr_5, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_3, [rb + input_hi], [ip + 5]
    add shr_5, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_e:
    add shl_2, [rb + input_lo], [ip + 5]
    add shr_6, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_2, [rb + input_hi], [ip + 5]
    add shr_6, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    jz  0, .flags

.by_f:
    add shl_1, [rb + input_lo], [ip + 5]
    add shr_7, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shl_1, [rb + input_hi], [ip + 5]
    add shr_7, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

.flags:
    # Update flags
    add bit_7, [rb + output_hi], [ip + 1]
    add [0], 0, [flag_carry]

    add bit_6, [rb + output_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + output_lo], 0, [rb - 3]
    add [rb + output_hi], 0, [rb - 4]
    arb -4
    call write_location_w

.done:
    arb 5
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; table, overflow_algorithm, input_lo, input_hi, output_lo, output_hi, count, tmp
    # Function with multiple entry points

execute_rcl_1_w:
    arb -8
    add 1, 0, [rb + count]
    add execute_rcl_rcr_w.rcl_table, 0, [rb + table]
    add execute_rcl_rcr_w.rcl_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcl_cl_w:
    arb -8
    add [reg_cl], 0, [rb + count]
    add execute_rcl_rcr_w.rcl_table, 0, [rb + table]
    add execute_rcl_rcr_w.rcl_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcr_1_w:
    arb -8
    add 1, 0, [rb + count]
    add execute_rcl_rcr_w.rcr_table, 0, [rb + table]
    add execute_rcl_rcr_w.rcr_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcr_cl_w:
    arb -8
    add [reg_cl], 0, [rb + count]
    add execute_rcl_rcr_w.rcr_table, 0, [rb + table]
    add execute_rcl_rcr_w.rcr_flags, 0, [rb + overflow_algorithm]

execute_rcl_rcr_w:
    # Use the mod17 table to obtain count mod 17
    add mod17, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Rotating by 0 (mod 17) is a no-operation, including flags
    jz  [rb + count], .done

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + input_lo]
    add [rb - 5], 0, [rb + input_hi]

    # Jump to the label that handles this case
    add [rb + table], [rb + count], [ip + 2]
    jz  0, [0]

.rcl_table:
    db 0
    db .by_1
    db .by_2
    db .by_3
    db .by_4
    db .by_5
    db .by_6
    db .by_7
    db .by_8
    db .by_9
    db .by_a
    db .by_b
    db .by_c
    db .by_d
    db .by_e
    db .by_f
    db .by_10

.rcr_table:
    db 0
    db .by_10
    db .by_f
    db .by_e
    db .by_d
    db .by_c
    db .by_b
    db .by_a
    db .by_9
    db .by_8
    db .by_7
    db .by_6
    db .by_5
    db .by_4
    db .by_3
    db .by_2
    db .by_1

.by_1:
    add shr_7, [rb + input_lo], [ip + 5]
    add shl_1, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl_1, [rb + input_lo], [ip + 1]
    add [0], [flag_carry], [rb + output_lo]

    add bit_7, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_2:
    add shr_6, [rb + input_lo], [ip + 5]
    add shl_2, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_7, [rb + input_hi], [ip + 5]
    add shl_2, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_6, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_3:
    add shr_5, [rb + input_lo], [ip + 5]
    add shl_3, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_6, [rb + input_hi], [ip + 5]
    add shl_3, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_5, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_4:
    add shr_4, [rb + input_lo], [ip + 5]
    add shl_4, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_5, [rb + input_hi], [ip + 5]
    add shl_4, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_4, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_5:
    add shr_3, [rb + input_lo], [ip + 5]
    add shl_5, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_4, [rb + input_hi], [ip + 5]
    add shl_5, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_3, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_6:
    add shr_2, [rb + input_lo], [ip + 5]
    add shl_6, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_3, [rb + input_hi], [ip + 5]
    add shl_6, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_2, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_7:
    add shr_1, [rb + input_lo], [ip + 5]
    add shl_7, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr_2, [rb + input_hi], [ip + 5]
    add shl_7, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_1, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_8:
    add [rb + input_lo], 0, [rb + output_hi]

    mul [flag_carry], 0x80, [rb + tmp]
    add shr_1, [rb + input_hi], [ip + 1]
    add [0], [rb + tmp], [rb + output_lo]

    add bit_0, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_9:
    add [rb + input_hi], 0, [rb + output_lo]

    add shl_1, [rb + input_lo], [ip + 1]
    add [0], [flag_carry], [rb + output_hi]

    add bit_7, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_a:
    add shr_7, [rb + input_lo], [ip + 5]
    add shl_1, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_7, [rb + input_hi], [ip + 5]
    add shl_2, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_6, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_b:
    add shr_6, [rb + input_lo], [ip + 5]
    add shl_2, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_6, [rb + input_hi], [ip + 5]
    add shl_3, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_5, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_c:
    add shr_5, [rb + input_lo], [ip + 5]
    add shl_3, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_5, [rb + input_hi], [ip + 5]
    add shl_4, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_4, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_d:
    add shr_4, [rb + input_lo], [ip + 5]
    add shl_4, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_4, [rb + input_hi], [ip + 5]
    add shl_5, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_3, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_e:
    add shr_3, [rb + input_lo], [ip + 5]
    add shl_5, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_3, [rb + input_hi], [ip + 5]
    add shl_6, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_2, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_f:
    add shr_2, [rb + input_lo], [ip + 5]
    add shl_6, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr_2, [rb + input_hi], [ip + 5]
    add shl_7, [rb + input_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_1, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.by_10:
    add shr_1, [rb + input_lo], [ip + 5]
    add shl_7, [rb + input_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x80, [rb + tmp]
    add shr_1, [rb + input_hi], [ip + 1]
    add [0], [rb + tmp], [rb + output_hi]

    add bit_0, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

.rcl_flags:
    # Update flags for rcl
    add bit_7, [rb + output_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, .store

.rcr_flags:
    # Update flags for rcr
    add bit_6, [rb + output_hi], [ip + 5]
    add bit_7, [rb + output_hi], [ip + 2]
    eq  [0], [0], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

.store:
    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + output_lo], 0, [rb - 3]
    add [rb + output_hi], 0, [rb - 4]
    arb -4
    call write_location_w

.done:
    arb 8
    ret 2
.ENDFRAME

.EOF
