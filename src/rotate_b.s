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
.FRAME loc_type, loc_addr; table, val, val_bits, val_times_8, not_sign, count, tmp
    # Function with multiple entry points

execute_rol_1_b:
    arb -7
    add 1, 0, [rb + count]
    add execute_rol_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_8

execute_rol_cl_b:
    arb -7
    add [reg_cl], 0, [rb + count]
    add execute_rol_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_8

execute_ror_1_b:
    arb -7
    add 1, 0, [rb + count]
    add execute_ror_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_8

execute_ror_cl_b:
    arb -7
    add [reg_cl], 0, [rb + count]
    add execute_ror_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_8

execute_rcl_1_b:
    arb -7
    add 1, 0, [rb + count]
    add execute_rcl_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_9

execute_rcl_cl_b:
    arb -7
    add [reg_cl], 0, [rb + count]
    add execute_rcl_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_9

execute_rcr_1_b:
    arb -7
    add 1, 0, [rb + count]
    add execute_rcr_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_9

execute_rcr_cl_b:
    arb -7
    add [reg_cl], 0, [rb + count]
    add execute_rcr_b_table, 0, [rb + table]
    jz  0, execute_rotate_b_mod_9

execute_rotate_b_mod_8:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_rotate_b_done

    # Use the split233 table to obtain count mod 8
    mul [rb + count], 3, [rb + tmp]
    add split233, [rb + tmp], [ip + 1]
    add [0], 0, [rb + count]

    jz  0, execute_rotate_b

execute_rotate_b_mod_9:
    # Rotating by 0 is a no-operation, including flags
    jz  [rb + count], execute_rotate_b_done

    # Use the mod9 table to obtain count mod 9
    add mod9, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

execute_rotate_b:
    # Read the value to rotate
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + val]

    # Expand val to bits
    mul [rb + val], 8, [rb + val_times_8]
    add bits, [rb + tmp], [rb + val_bits]

    # Save negation of the sign for later
    lt  [rb + val], 0x80, [rb + not_sign]

    # Jump to rotate by count
    add [rb + table], [rb + count], [ip + 2]
    jz  0, [0]

execute_rol_b_table:
    db execute_rol_b_by_8
    db execute_rol_b_by_1
    db execute_rol_b_by_2
    db execute_rol_b_by_3
    db execute_rol_b_by_4
    db execute_rol_b_by_5
    db execute_rol_b_by_6
    db execute_rol_b_by_7

execute_ror_b_table:
    db execute_ror_b_by_8
    db execute_ror_b_by_1
    db execute_ror_b_by_2
    db execute_ror_b_by_3
    db execute_ror_b_by_4
    db execute_ror_b_by_5
    db execute_ror_b_by_6
    db execute_ror_b_by_7

execute_rcl_b_table:
    db execute_rcl_b_by_9
    db execute_rcl_b_by_1
    db execute_rcl_b_by_2
    db execute_rcl_b_by_3
    db execute_rcl_b_by_4
    db execute_rcl_b_by_5
    db execute_rcl_b_by_6
    db execute_rcl_b_by_7
    db execute_rcl_b_by_8

execute_rcr_b_table:
    db execute_rcl_b_by_9
    db execute_rcl_b_by_8
    db execute_rcl_b_by_7
    db execute_rcl_b_by_6
    db execute_rcl_b_by_5
    db execute_rcl_b_by_4
    db execute_rcl_b_by_3
    db execute_rcl_b_by_2
    db execute_rcl_b_by_1

execute_rol_b_by_8:
    # Value is not changed, update just the flags
    add bits, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_rotate_b_done

execute_rol_b_by_1:
    add shr + 7, [rb + val_times_8], [ip + 5]
    add shl + 1, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 7, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 6, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rol_b_by_2:
    add shr + 6, [rb + val_times_8], [ip + 5]
    add shl + 2, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 6, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 5, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rol_b_by_3:
    add shr + 5, [rb + val_times_8], [ip + 5]
    add shl + 3, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 5, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 4, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rol_b_by_4:
    add shr + 4, [rb + val_times_8], [ip + 5]
    add shl + 4, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 4, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 3, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rol_b_by_5:
    add shr + 3, [rb + val_times_8], [ip + 5]
    add shl + 5, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 3, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 2, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rol_b_by_6:
    add shr + 2, [rb + val_times_8], [ip + 5]
    add shl + 6, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 2, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 1, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rol_b_by_7:
    add shr + 1, [rb + val_times_8], [ip + 5]
    add shl + 7, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 1, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 0, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_8:
    # Value is not changed, update just the flags
    add bits + 7, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add 0, 0, [flag_overflow]

    jz  0, execute_rotate_b_done

execute_ror_b_by_1:
    add shl + 7, [rb + val_times_8], [ip + 5]
    add shr + 1, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 0, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_2:
    add shl + 6, [rb + val_times_8], [ip + 5]
    add shr + 2, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 1, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_3:
    add shl + 5, [rb + val_times_8], [ip + 5]
    add shr + 3, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 2, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_4:
    add shl + 4, [rb + val_times_8], [ip + 5]
    add shr + 4, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 3, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_5:
    add shl + 3, [rb + val_times_8], [ip + 5]
    add shr + 5, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 4, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_6:
    add shl + 2, [rb + val_times_8], [ip + 5]
    add shr + 6, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 5, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_ror_b_by_7:
    add shl + 1, [rb + val_times_8], [ip + 5]
    add shr + 7, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]

    add bits + 6, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    eq  [flag_carry], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_9:
    # Value and carry are not changed, overflow is zero
    add 0, 0, [flag_overflow]
    jz  0, execute_rotate_b_done

execute_rcl_b_by_1:
    add shl + 1, [rb + val_times_8], [ip + 1]
    add [0], [flag_carry], [rb + val]

    add bits + 7, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 6, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_2:
    add shr + 7, [rb + val_times_8], [ip + 5]
    add shl + 2, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 6, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 5, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_3:
    add shr + 6, [rb + val_times_8], [ip + 5]
    add shl + 3, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 5, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 4, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_4:
    add shr + 5, [rb + val_times_8], [ip + 5]
    add shl + 4, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 4, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 3, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_5:
    add shr + 4, [rb + val_times_8], [ip + 5]
    add shl + 5, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 3, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 2, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_6:
    add shr + 3, [rb + val_times_8], [ip + 5]
    add shl + 6, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 2, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 1, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_7:
    add shr + 2, [rb + val_times_8], [ip + 5]
    add shl + 7, [rb + val_times_8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 1, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]
    add bits + 0, [rb + val_times_8], [ip + 1]
    eq  [0], [rb + not_sign], [flag_overflow]

    jz  0, execute_rotate_b_store

execute_rcl_b_by_8:
    add shr + 1, [rb + val_times_8], [ip + 5]
    mul [flag_carry], 0x80, [rb + tmp]
    add [0], [rb + tmp], [rb + val]

    eq  [flag_carry], [rb + not_sign], [flag_overflow]
    add bits + 0, [rb + val_times_8], [ip + 1]
    add [0], 0, [flag_carry]

execute_rotate_b_store:
    # Write the shifted value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

execute_rotate_b_done:
    arb 7
    ret 2
.ENDFRAME

.EOF
