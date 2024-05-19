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

# From obj/bits.s
.IMPORT bits

# From obj/mod9.s
.IMPORT mod9

# From obj/shl.s
.IMPORT shl

# From obj/shr.s
.IMPORT shr

# From obj/split233.s
.IMPORT split233

# From state.s
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_overflow

##########
.FRAME lseg, loff; val, valx8, count, tmp
    # Function with multiple entry points

execute_rol_1_b:
    arb -4
    add 1, 0, [rb + count]
    jz  0, execute_rol_b

execute_rol_cl_b:
    arb -4
    add [reg_cl], 0, [rb + count]

execute_rol_b:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_rol_b_done

    # Use the split233 table to obtain count mod 8
    mul [rb + count], 3, [rb + tmp]
    add split233, [rb + tmp], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]
    mul [rb - 4], 8, [rb + valx8]

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
    add shr + 7, [rb + valx8], [ip + 5]
    add shl + 1, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_2:
    add shr + 6, [rb + valx8], [ip + 5]
    add shl + 2, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_3:
    add shr + 5, [rb + valx8], [ip + 5]
    add shl + 3, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_4:
    add shr + 4, [rb + valx8], [ip + 5]
    add shl + 4, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_5:
    add shr + 3, [rb + valx8], [ip + 5]
    add shl + 5, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_6:
    add shr + 2, [rb + valx8], [ip + 5]
    add shl + 6, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_rol_b_flags

execute_rol_b_by_7:
    add shr + 1, [rb + valx8], [ip + 5]
    add shl + 7, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]

execute_rol_b_flags:
    # Update flags
    mul [rb + val], 8, [rb + valx8]

    add bits + 0, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    add bits + 7, [rb + valx8], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_rol_b_done:
    arb 4
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; val, valx8, count, tmp
    # Function with multiple entry points

execute_ror_1_b:
    arb -4
    add 1, 0, [rb + count]
    jz  0, execute_ror_b

execute_ror_cl_b:
    arb -4
    add [reg_cl], 0, [rb + count]

execute_ror_b:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_ror_b_done

    # Use the split233 table to obtain count mod 8
    mul [rb + count], 3, [rb + tmp]
    add split233, [rb + tmp], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]
    mul [rb - 4], 8, [rb + valx8]

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
    add shl + 7, [rb + valx8], [ip + 5]
    add shr + 1, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_2:
    add shl + 6, [rb + valx8], [ip + 5]
    add shr + 2, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_3:
    add shl + 5, [rb + valx8], [ip + 5]
    add shr + 3, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_4:
    add shl + 4, [rb + valx8], [ip + 5]
    add shr + 4, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_5:
    add shl + 3, [rb + valx8], [ip + 5]
    add shr + 5, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_6:
    add shl + 2, [rb + valx8], [ip + 5]
    add shr + 6, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    jz  0, execute_ror_b_flags

execute_ror_b_by_7:
    add shl + 1, [rb + valx8], [ip + 5]
    add shr + 7, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]

execute_ror_b_flags:
    # Update flags
    mul [rb + val], 8, [rb + valx8]

    add bits + 7, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    add bits + 6, [rb + valx8], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_ror_b_done:
    arb 4
    ret 2
.ENDFRAME

##########
.FRAME lseg, loff; table, overflow_algorithm, val, valx8, count, tmp
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
    add [rb - 4], 0, [rb + val]
    mul [rb - 4], 8, [rb + valx8]

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
    add shl + 1, [rb + valx8], [ip + 1]
    add [0], [flag_carry], [rb + val]

    add bits + 7, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_2:
    add shr + 7, [rb + valx8], [ip + 5]
    add shl + 2, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 6, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_3:
    add shr + 6, [rb + valx8], [ip + 5]
    add shl + 3, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 5, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_4:
    add shr + 5, [rb + valx8], [ip + 5]
    add shl + 4, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 4, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_5:
    add shr + 4, [rb + valx8], [ip + 5]
    add shl + 5, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 3, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_6:
    add shr + 3, [rb + valx8], [ip + 5]
    add shl + 6, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 2, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_7:
    add shr + 2, [rb + valx8], [ip + 5]
    add shl + 7, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 1, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_by_8:
    add shr + 1, [rb + valx8], [ip + 5]
    mul [flag_carry], 0x80, [rb + tmp]
    add [0], [rb + tmp], [rb + val]

    add bits + 0, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_b_flags:
    # Update flags for rcl
    mul [rb + val], 8, [rb + valx8]

    add bits + 7, [rb + valx8], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_rcl_rcr_b_store

execute_rcr_b_flags:
    # Update flags for rcr
    mul [rb + val], 8, [rb + valx8]

    add bits + 6, [rb + valx8], [ip + 5]
    add bits + 7, [rb + valx8], [ip + 2]
    eq  [0], [0], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

execute_rcl_rcr_b_store:
    # Write the rotated value
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_rcl_rcr_b_done:
    arb 6
    ret 2
.ENDFRAME

.EOF
