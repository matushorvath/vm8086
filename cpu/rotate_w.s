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
.IMPORT shl

# From util/shr.s
.IMPORT shr

# From state.s
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_overflow

##########
.FRAME lseg, loff; val_lo, val_hi, valx8_lo, valx8_hi, count, tmp
    # Function with multiple entry points

execute_rol_1_w:
    arb -6
    add 1, 0, [rb + count]
    jz  0, execute_rol_w

execute_rol_cl_w:
    arb -6
    add [reg_cl], 0, [rb + count]

execute_rol_w:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_rol_w_done

    # Use the nibbles table to obtain count mod 16
    add nibble_0, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val_lo]
    mul [rb - 4], 8, [rb + valx8_lo]
    add [rb - 5], 0, [rb + val_hi]
    mul [rb - 5], 8, [rb + valx8_hi]

    # Jump to the label that handles this case
    add execute_rol_w_table, [rb + count], [ip + 2]
    jz  0, [0]

execute_rol_w_table:
    db execute_rol_w_flags
    db execute_rol_w_by_1
    db execute_rol_w_by_2
    db execute_rol_w_by_3
    db execute_rol_w_by_4
    db execute_rol_w_by_5
    db execute_rol_w_by_6
    db execute_rol_w_by_7
    db execute_rol_w_by_8
    db execute_rol_w_by_9
    db execute_rol_w_by_a
    db execute_rol_w_by_b
    db execute_rol_w_by_c
    db execute_rol_w_by_d
    db execute_rol_w_by_e
    db execute_rol_w_by_f

execute_rol_w_by_1:
    add shr + 7, [rb + valx8_hi], [ip + 5]
    add shl + 1, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 7, [rb + valx8_lo], [ip + 5]
    add shl + 1, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_2:
    add shr + 6, [rb + valx8_hi], [ip + 5]
    add shl + 2, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 6, [rb + valx8_lo], [ip + 5]
    add shl + 2, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_3:
    add shr + 5, [rb + valx8_hi], [ip + 5]
    add shl + 3, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 5, [rb + valx8_lo], [ip + 5]
    add shl + 3, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_4:
    add shr + 4, [rb + valx8_hi], [ip + 5]
    add shl + 4, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 4, [rb + valx8_lo], [ip + 5]
    add shl + 4, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_5:
    add shr + 3, [rb + valx8_hi], [ip + 5]
    add shl + 5, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 3, [rb + valx8_lo], [ip + 5]
    add shl + 5, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_6:
    add shr + 2, [rb + valx8_hi], [ip + 5]
    add shl + 6, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 2, [rb + valx8_lo], [ip + 5]
    add shl + 6, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_7:
    add shr + 1, [rb + valx8_hi], [ip + 5]
    add shl + 7, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shr + 1, [rb + valx8_lo], [ip + 5]
    add shl + 7, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_8:
    add [rb + val_lo], 0, [rb + tmp]
    add [rb + val_hi], 0, [rb + val_lo]
    add [rb + tmp], 0, [rb + val_hi]

    jz  0, execute_rol_w_flags

execute_rol_w_by_9:
    add shr + 7, [rb + valx8_hi], [ip + 5]
    add shl + 1, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 7, [rb + valx8_lo], [ip + 5]
    add shl + 1, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_rol_w_flags

execute_rol_w_by_a:
    add shr + 6, [rb + valx8_hi], [ip + 5]
    add shl + 2, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 6, [rb + valx8_lo], [ip + 5]
    add shl + 2, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_rol_w_flags

execute_rol_w_by_b:
    add shr + 5, [rb + valx8_hi], [ip + 5]
    add shl + 3, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 5, [rb + valx8_lo], [ip + 5]
    add shl + 3, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_rol_w_flags

execute_rol_w_by_c:
    add shr + 4, [rb + valx8_hi], [ip + 5]
    add shl + 4, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 4, [rb + valx8_lo], [ip + 5]
    add shl + 4, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_rol_w_flags

execute_rol_w_by_d:
    add shr + 3, [rb + valx8_hi], [ip + 5]
    add shl + 5, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 3, [rb + valx8_lo], [ip + 5]
    add shl + 5, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_rol_w_flags

execute_rol_w_by_e:
    add shr + 2, [rb + valx8_hi], [ip + 5]
    add shl + 6, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 2, [rb + valx8_lo], [ip + 5]
    add shl + 6, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_rol_w_flags

execute_rol_w_by_f:
    add shr + 1, [rb + valx8_hi], [ip + 5]
    add shl + 7, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shr + 1, [rb + valx8_lo], [ip + 5]
    add shl + 7, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

execute_rol_w_flags:
    # Update flags
    add bit_0, [rb + val_lo], [ip + 1]
    add [0], 0, [flag_carry]

    add bit_7, [rb + val_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_rol_w_done:
    arb 6
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; val_lo, val_hi, valx8_lo, valx8_hi, count, tmp
    # Function with multiple entry points

execute_ror_1_w:
    arb -6
    add 1, 0, [rb + count]
    jz  0, execute_ror_w

execute_ror_cl_w:
    arb -6
    add [reg_cl], 0, [rb + count]

execute_ror_w:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_ror_w_done

    # Use the nibbles table to obtain count mod 16
    add nibble_0, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val_lo]
    mul [rb - 4], 8, [rb + valx8_lo]
    add [rb - 5], 0, [rb + val_hi]
    mul [rb - 5], 8, [rb + valx8_hi]

    # Jump to the label that handles this case
    add execute_ror_w_table, [rb + count], [ip + 2]
    jz  0, [0]

execute_ror_w_table:
    db execute_ror_w_flags
    db execute_ror_w_by_1
    db execute_ror_w_by_2
    db execute_ror_w_by_3
    db execute_ror_w_by_4
    db execute_ror_w_by_5
    db execute_ror_w_by_6
    db execute_ror_w_by_7
    db execute_ror_w_by_8
    db execute_ror_w_by_9
    db execute_ror_w_by_a
    db execute_ror_w_by_b
    db execute_ror_w_by_c
    db execute_ror_w_by_d
    db execute_ror_w_by_e
    db execute_ror_w_by_f

execute_ror_w_by_1:
    add shl + 7, [rb + valx8_lo], [ip + 5]
    add shr + 1, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 7, [rb + valx8_hi], [ip + 5]
    add shr + 1, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_2:
    add shl + 6, [rb + valx8_lo], [ip + 5]
    add shr + 2, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 6, [rb + valx8_hi], [ip + 5]
    add shr + 2, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_3:
    add shl + 5, [rb + valx8_lo], [ip + 5]
    add shr + 3, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 5, [rb + valx8_hi], [ip + 5]
    add shr + 3, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_4:
    add shl + 4, [rb + valx8_lo], [ip + 5]
    add shr + 4, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 4, [rb + valx8_hi], [ip + 5]
    add shr + 4, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_5:
    add shl + 3, [rb + valx8_lo], [ip + 5]
    add shr + 5, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 3, [rb + valx8_hi], [ip + 5]
    add shr + 5, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_6:
    add shl + 2, [rb + valx8_lo], [ip + 5]
    add shr + 6, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 2, [rb + valx8_hi], [ip + 5]
    add shr + 6, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_7:
    add shl + 1, [rb + valx8_lo], [ip + 5]
    add shr + 7, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_hi]

    add shl + 1, [rb + valx8_hi], [ip + 5]
    add shr + 7, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_8:
    add [rb + val_hi], 0, [rb + tmp]
    add [rb + val_lo], 0, [rb + val_hi]
    add [rb + tmp], 0, [rb + val_lo]

    jz  0, execute_ror_w_flags

execute_ror_w_by_9:
    add shl + 7, [rb + valx8_lo], [ip + 5]
    add shr + 1, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 7, [rb + valx8_hi], [ip + 5]
    add shr + 1, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_ror_w_flags

execute_ror_w_by_a:
    add shl + 6, [rb + valx8_lo], [ip + 5]
    add shr + 2, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 6, [rb + valx8_hi], [ip + 5]
    add shr + 2, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_ror_w_flags

execute_ror_w_by_b:
    add shl + 5, [rb + valx8_lo], [ip + 5]
    add shr + 3, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 5, [rb + valx8_hi], [ip + 5]
    add shr + 3, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_ror_w_flags

execute_ror_w_by_c:
    add shl + 4, [rb + valx8_lo], [ip + 5]
    add shr + 4, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 4, [rb + valx8_hi], [ip + 5]
    add shr + 4, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_ror_w_flags

execute_ror_w_by_d:
    add shl + 3, [rb + valx8_lo], [ip + 5]
    add shr + 5, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 3, [rb + valx8_hi], [ip + 5]
    add shr + 5, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_ror_w_flags

execute_ror_w_by_e:
    add shl + 2, [rb + valx8_lo], [ip + 5]
    add shr + 6, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 2, [rb + valx8_hi], [ip + 5]
    add shr + 6, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

    jz  0, execute_ror_w_flags

execute_ror_w_by_f:
    add shl + 1, [rb + valx8_lo], [ip + 5]
    add shr + 7, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + val_lo]

    add shl + 1, [rb + valx8_hi], [ip + 5]
    add shr + 7, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + val_hi]

execute_ror_w_flags:
    # Update flags
    add bit_7, [rb + val_hi], [ip + 1]
    add [0], 0, [flag_carry]

    add bit_6, [rb + val_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_ror_w_done:
    arb 6
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; table, overflow_algorithm, input_lo, input_hi, output_lo, output_hi, valx8_lo, valx8_hi, count, tmp
    # Function with multiple entry points

execute_rcl_1_w:
    arb -10
    add 1, 0, [rb + count]
    add execute_rcl_w_table, 0, [rb + table]
    add execute_rcl_w_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcl_cl_w:
    arb -10
    add [reg_cl], 0, [rb + count]
    add execute_rcl_w_table, 0, [rb + table]
    add execute_rcl_w_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcr_1_w:
    arb -10
    add 1, 0, [rb + count]
    add execute_rcr_w_table, 0, [rb + table]
    add execute_rcr_w_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcr_cl_w:
    arb -10
    add [reg_cl], 0, [rb + count]
    add execute_rcr_w_table, 0, [rb + table]
    add execute_rcr_w_flags, 0, [rb + overflow_algorithm]

execute_rcl_rcr_w:
    # Use the mod17 table to obtain count mod 17
    add mod17, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Rotating by 0 (mod 17) is a no-operation, including flags
    jz  [rb + count], execute_rcl_rcr_w_done

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + input_lo]
    mul [rb - 4], 8, [rb + valx8_lo]
    add [rb - 5], 0, [rb + input_hi]
    mul [rb - 5], 8, [rb + valx8_hi]

    # Jump to the label that handles this case
    add [rb + table], [rb + count], [ip + 2]
    jz  0, [0]

execute_rcl_w_table:
    db 0
    db execute_rcl_w_by_1
    db execute_rcl_w_by_2
    db execute_rcl_w_by_3
    db execute_rcl_w_by_4
    db execute_rcl_w_by_5
    db execute_rcl_w_by_6
    db execute_rcl_w_by_7
    db execute_rcl_w_by_8
    db execute_rcl_w_by_9
    db execute_rcl_w_by_a
    db execute_rcl_w_by_b
    db execute_rcl_w_by_c
    db execute_rcl_w_by_d
    db execute_rcl_w_by_e
    db execute_rcl_w_by_f
    db execute_rcl_w_by_10

execute_rcr_w_table:
    db 0
    db execute_rcl_w_by_10
    db execute_rcl_w_by_f
    db execute_rcl_w_by_e
    db execute_rcl_w_by_d
    db execute_rcl_w_by_c
    db execute_rcl_w_by_b
    db execute_rcl_w_by_a
    db execute_rcl_w_by_9
    db execute_rcl_w_by_8
    db execute_rcl_w_by_7
    db execute_rcl_w_by_6
    db execute_rcl_w_by_5
    db execute_rcl_w_by_4
    db execute_rcl_w_by_3
    db execute_rcl_w_by_2
    db execute_rcl_w_by_1

execute_rcl_w_by_1:
    add shr + 7, [rb + valx8_lo], [ip + 5]
    add shl + 1, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shl + 1, [rb + valx8_lo], [ip + 1]
    add [0], [flag_carry], [rb + output_lo]

    add bit_7, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_2:
    add shr + 6, [rb + valx8_lo], [ip + 5]
    add shl + 2, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr + 7, [rb + valx8_hi], [ip + 5]
    add shl + 2, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_6, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_3:
    add shr + 5, [rb + valx8_lo], [ip + 5]
    add shl + 3, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr + 6, [rb + valx8_hi], [ip + 5]
    add shl + 3, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_5, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_4:
    add shr + 4, [rb + valx8_lo], [ip + 5]
    add shl + 4, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr + 5, [rb + valx8_hi], [ip + 5]
    add shl + 4, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_4, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_5:
    add shr + 3, [rb + valx8_lo], [ip + 5]
    add shl + 5, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr + 4, [rb + valx8_hi], [ip + 5]
    add shl + 5, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_3, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_6:
    add shr + 2, [rb + valx8_lo], [ip + 5]
    add shl + 6, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr + 3, [rb + valx8_hi], [ip + 5]
    add shl + 6, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_2, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_7:
    add shr + 1, [rb + valx8_lo], [ip + 5]
    add shl + 7, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_hi]

    add shr + 2, [rb + valx8_hi], [ip + 5]
    add shl + 7, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + output_lo], [rb + tmp], [rb + output_lo]

    add bit_1, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_8:
    add [rb + input_lo], 0, [rb + output_hi]

    mul [flag_carry], 0x80, [rb + tmp]
    add shr + 1, [rb + valx8_hi], [ip + 1]
    add [0], [rb + tmp], [rb + output_lo]

    add bit_0, [rb + input_hi], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_9:
    add [rb + input_hi], 0, [rb + output_lo]

    add shl + 1, [rb + valx8_lo], [ip + 1]
    add [0], [flag_carry], [rb + output_hi]

    add bit_7, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_a:
    add shr + 7, [rb + valx8_lo], [ip + 5]
    add shl + 1, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr + 7, [rb + valx8_hi], [ip + 5]
    add shl + 2, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_6, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_b:
    add shr + 6, [rb + valx8_lo], [ip + 5]
    add shl + 2, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr + 6, [rb + valx8_hi], [ip + 5]
    add shl + 3, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_5, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_c:
    add shr + 5, [rb + valx8_lo], [ip + 5]
    add shl + 3, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr + 5, [rb + valx8_hi], [ip + 5]
    add shl + 4, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_4, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_d:
    add shr + 4, [rb + valx8_lo], [ip + 5]
    add shl + 4, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr + 4, [rb + valx8_hi], [ip + 5]
    add shl + 5, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_3, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_e:
    add shr + 3, [rb + valx8_lo], [ip + 5]
    add shl + 5, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr + 3, [rb + valx8_hi], [ip + 5]
    add shl + 6, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_2, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_f:
    add shr + 2, [rb + valx8_lo], [ip + 5]
    add shl + 6, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    add shr + 2, [rb + valx8_hi], [ip + 5]
    add shl + 7, [rb + valx8_lo], [ip + 2]
    add [0], [0], [rb + output_hi]

    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + output_hi], [rb + tmp], [rb + output_hi]

    add bit_1, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_10:
    add shr + 1, [rb + valx8_lo], [ip + 5]
    add shl + 7, [rb + valx8_hi], [ip + 2]
    add [0], [0], [rb + output_lo]

    mul [flag_carry], 0x80, [rb + tmp]
    add shr + 1, [rb + valx8_hi], [ip + 1]
    add [0], [rb + tmp], [rb + output_hi]

    add bit_0, [rb + input_lo], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_flags:
    # Update flags for rcl
    add bit_7, [rb + output_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_rcl_rcr_w_store

execute_rcr_w_flags:
    # Update flags for rcr
    add bit_6, [rb + output_hi], [ip + 5]
    add bit_7, [rb + output_hi], [ip + 2]
    eq  [0], [0], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

execute_rcl_rcr_w_store:
    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + output_lo], 0, [rb - 3]
    add [rb + output_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_rcl_rcr_w_done:
    arb 10
    ret 2
.ENDFRAME

.EOF
