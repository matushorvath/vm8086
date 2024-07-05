.EXPORT execute_rol_1_b
.EXPORT execute_rol_cl_b
.EXPORT execute_ror_1_b
.EXPORT execute_ror_cl_b
.EXPORT execute_rcl_1_b
.EXPORT execute_rcl_cl_b
.EXPORT execute_rcr_1_b
.EXPORT execute_rcr_cl_b

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_1
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5
.IMPORT bit_6
.IMPORT bit_7

# From util/mod9.s
.IMPORT mod9

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

# From util/split233.s
.IMPORT split233_0

# From state.s
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_overflow

##########
.FRAME lseg, loff; val, count
    # Function with multiple entry points

execute_rol_1_b:
    arb -2
    add 1, 0, [rb + count]
    jz  0, execute_rol_b

execute_rol_cl_b:
    arb -2
    add [reg_cl], 0, [rb + count]

execute_rol_b:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_rol_b_done

    # Use the split233 table to obtain count mod 8
    add split233_0, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # Jump to the label that handles this case
    add execute_rol_b_table, [rb + count], [ip + 2]
    jz  0, [0]

execute_rol_b_table:
    db execute_rol_b_flags
    db execute_rol_b_by_1
    db execute_rol_b_by_2
    db execute_rol_b_by_3
    db execute_rol_b_by_4
    db execute_rol_b_by_5
    db execute_rol_b_by_6
    db execute_rol_b_by_7

execute_rol_b_by_1:
    add shr_7, [rb + val], [ip + 5]
    add shl_1, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_2:
    add shr_6, [rb + val], [ip + 5]
    add shl_2, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_3:
    add shr_5, [rb + val], [ip + 5]
    add shl_3, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_4:
    add shr_4, [rb + val], [ip + 5]
    add shl_4, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_5:
    add shr_3, [rb + val], [ip + 5]
    add shl_5, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_6:
    add shr_2, [rb + val], [ip + 5]
    add shl_6, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_7:
    add shr_1, [rb + val], [ip + 5]
    add shl_7, [rb + val], [ip + 2]
    add [0], [0], [rb + val]

execute_rol_b_flags:
    # Update flags
    add bit_0, [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    add bit_7, [rb + val], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_rol_b_done:
    arb 2
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; val, count
    # Function with multiple entry points

execute_ror_1_b:
    arb -2
    add 1, 0, [rb + count]
    jz  0, execute_ror_b

execute_ror_cl_b:
    arb -2
    add [reg_cl], 0, [rb + count]

execute_ror_b:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_ror_b_done

    # Use the split233 table to obtain count mod 8
    add split233_0, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # Jump to the label that handles this case
    add execute_ror_b_table, [rb + count], [ip + 2]
    jz  0, [0]

execute_ror_b_table:
    db execute_ror_b_flags
    db execute_ror_b_by_1
    db execute_ror_b_by_2
    db execute_ror_b_by_3
    db execute_ror_b_by_4
    db execute_ror_b_by_5
    db execute_ror_b_by_6
    db execute_ror_b_by_7

execute_ror_b_by_1:
    add shl_7, [rb + val], [ip + 5]
    add shr_1, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_2:
    add shl_6, [rb + val], [ip + 5]
    add shr_2, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_3:
    add shl_5, [rb + val], [ip + 5]
    add shr_3, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_4:
    add shl_4, [rb + val], [ip + 5]
    add shr_4, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_5:
    add shl_3, [rb + val], [ip + 5]
    add shr_5, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_6:
    add shl_2, [rb + val], [ip + 5]
    add shr_6, [rb + val], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_7:
    add shl_1, [rb + val], [ip + 5]
    add shr_7, [rb + val], [ip + 2]
    add [0], [0], [rb + val]

execute_ror_b_flags:
    # Update flags
    add bit_7, [rb + val], [ip + 1]
    add [0], 0, [flag_carry]

    add bit_6, [rb + val], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_ror_b_done:
    arb 2
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; table, overflow_algorithm, input, output, count, tmp
    # Function with multiple entry points

execute_rcl_1_b:
    arb -6
    add 1, 0, [rb + count]
    add execute_rcl_b_table, 0, [rb + table]
    add execute_rcl_b_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_b

execute_rcl_cl_b:
    arb -6
    add [reg_cl], 0, [rb + count]
    add execute_rcl_b_table, 0, [rb + table]
    add execute_rcl_b_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_b

execute_rcr_1_b:
    arb -6
    add 1, 0, [rb + count]
    add execute_rcr_b_table, 0, [rb + table]
    add execute_rcr_b_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_b

execute_rcr_cl_b:
    arb -6
    add [reg_cl], 0, [rb + count]
    add execute_rcr_b_table, 0, [rb + table]
    add execute_rcr_b_flags, 0, [rb + overflow_algorithm]

execute_rcl_rcr_b:
    # Use the mod9 table to obtain count mod 9
    add mod9, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Rotating by 0 (mod 9) is a no-operation, including flags
    jz  [rb + count], execute_rcl_rcr_b_done

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + input]

    # Jump to the label that handles this case
    add [rb + table], [rb + count], [ip + 2]
    jz  0, [0]

execute_rcl_b_table:
    db 0
    db execute_rcl_b_by_1
    db execute_rcl_b_by_2
    db execute_rcl_b_by_3
    db execute_rcl_b_by_4
    db execute_rcl_b_by_5
    db execute_rcl_b_by_6
    db execute_rcl_b_by_7
    db execute_rcl_b_by_8

execute_rcr_b_table:
    db 0
    db execute_rcl_b_by_8
    db execute_rcl_b_by_7
    db execute_rcl_b_by_6
    db execute_rcl_b_by_5
    db execute_rcl_b_by_4
    db execute_rcl_b_by_3
    db execute_rcl_b_by_2
    db execute_rcl_b_by_1

execute_rcl_b_by_1:
    add shl_1, [rb + input], [ip + 1]
    add [0], [flag_carry], [rb + output]

    add bit_7, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_2:
    add shr_7, [rb + input], [ip + 5]
    add shl_2, [rb + input], [ip + 2]
    add [0], [0], [rb + output]
    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + output], [rb + tmp], [rb + output]

    add bit_6, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_3:
    add shr_6, [rb + input], [ip + 5]
    add shl_3, [rb + input], [ip + 2]
    add [0], [0], [rb + output]
    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + output], [rb + tmp], [rb + output]

    add bit_5, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_4:
    add shr_5, [rb + input], [ip + 5]
    add shl_4, [rb + input], [ip + 2]
    add [0], [0], [rb + output]
    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + output], [rb + tmp], [rb + output]

    add bit_4, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_5:
    add shr_4, [rb + input], [ip + 5]
    add shl_5, [rb + input], [ip + 2]
    add [0], [0], [rb + output]
    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + output], [rb + tmp], [rb + output]

    add bit_3, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_6:
    add shr_3, [rb + input], [ip + 5]
    add shl_6, [rb + input], [ip + 2]
    add [0], [0], [rb + output]
    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + output], [rb + tmp], [rb + output]

    add bit_2, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_7:
    add shr_2, [rb + input], [ip + 5]
    add shl_7, [rb + input], [ip + 2]
    add [0], [0], [rb + output]
    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + output], [rb + tmp], [rb + output]

    add bit_1, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_8:
    add shr_1, [rb + input], [ip + 5]
    mul [flag_carry], 0x80, [rb + tmp]
    add [0], [rb + tmp], [rb + output]

    add bit_0, [rb + input], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_flags:
    # Update flags for rcl
    add bit_7, [rb + output], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_rcl_rcr_b_store

execute_rcr_b_flags:
    # Update flags for rcr
    add bit_6, [rb + output], [ip + 5]
    add bit_7, [rb + output], [ip + 2]
    eq  [0], [0], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

execute_rcl_rcr_b_store:
    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + output], 0, [rb - 3]
    arb -3
    call write_location_b

execute_rcl_rcr_b_done:
    arb 6
    ret 2
.ENDFRAME

.EOF
