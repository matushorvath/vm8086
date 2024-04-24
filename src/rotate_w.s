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

# From obj/bits.s
.IMPORT bits

# From obj/nibbles.s
.IMPORT nibbles

# From obj/shl.s
.IMPORT shl

# From obj/shr.s
.IMPORT shr

# From state.s
.IMPORT reg_cl
.IMPORT flag_carry
.IMPORT flag_overflow

# TODO remove
execute_rcl_1_w:
execute_rcr_1_w:
execute_rcl_cl_w:
execute_rcr_cl_w:

##########
.FRAME loc_type, loc_addr; val_lo, val_hi, valx8_lo, valx8_hi, count, tmp
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
    mul [rb + count], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
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
    mul [rb + val_lo], 8, [rb + valx8_lo]
    mul [rb + val_hi], 8, [rb + valx8_hi]

    add bits + 0, [rb + valx8_lo], [ip + 1]
    add [0], 0, [flag_carry]

    add bits + 7, [rb + valx8_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the retated value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_rol_w_done:
    arb 6
    ret 2
.ENDFRAME

##########
.FRAME loc_type, loc_addr; val_lo, val_hi, valx8_lo, valx8_hi, count, tmp
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
    mul [rb + count], 2, [rb + tmp]
    add nibbles, [rb + tmp], [ip + 1]
    add [0], 0, [rb + count]

    # Read the value to rotate
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
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
    mul [rb + val_hi], 8, [rb + valx8_hi]

    add bits + 7, [rb + valx8_hi], [ip + 1]
    add [0], 0, [flag_carry]

    add bits + 6, [rb + valx8_hi], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    # Write the retated value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val_lo], 0, [rb - 3]
    add [rb + val_hi], 0, [rb - 4]
    arb -4
    call write_location_w

execute_ror_w_done:
    arb 6
    ret 2
.ENDFRAME

# TODO remove
.EOF

##########
.FRAME loc_type, loc_addr; table, overflow_algorithm, val, valx8, count, tmp
    # Function with multiple entry points

execute_rcl_1_w:
    arb -6
    add 1, 0, [rb + count]
    add execute_rcl_w_table, 0, [rb + table]
    add execute_rcl_w_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcl_cl_w:
    arb -6
    add [reg_cl], 0, [rb + count]
    add execute_rcl_w_table, 0, [rb + table]
    add execute_rcl_w_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcr_1_w:
    arb -6
    add 1, 0, [rb + count]
    add execute_rcr_w_table, 0, [rb + table]
    add execute_rcr_w_flags, 0, [rb + overflow_algorithm]
    jz  0, execute_rcl_rcr_w

execute_rcr_cl_w:
    arb -6
    add [reg_cl], 0, [rb + count]
    add execute_rcr_w_table, 0, [rb + table]
    add execute_rcr_w_flags, 0, [rb + overflow_algorithm]

execute_rcl_rcr_w:
    # Use the mod9 table to obtain count mod 9
    add mod9, [rb + count], [ip + 1]
    add [0], 0, [rb + count]

    # Rotating by 0 (mod 9) is a no-operation, including flags
    jz  [rb + count], execute_rcl_rcr_w_done

    # Read the value to rotate
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + val]
    mul [rb - 4], 8, [rb + valx8]

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

execute_rcr_w_table:
    db 0
    db execute_rcl_w_by_8
    db execute_rcl_w_by_7
    db execute_rcl_w_by_6
    db execute_rcl_w_by_5
    db execute_rcl_w_by_4
    db execute_rcl_w_by_3
    db execute_rcl_w_by_2
    db execute_rcl_w_by_1

execute_rcl_w_by_1:
    add shl + 1, [rb + valx8], [ip + 1]
    add [0], [flag_carry], [rb + val]

    add bits + 7, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_2:
    add shr + 7, [rb + valx8], [ip + 5]
    add shl + 2, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x02, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 6, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_3:
    add shr + 6, [rb + valx8], [ip + 5]
    add shl + 3, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x04, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 5, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_4:
    add shr + 5, [rb + valx8], [ip + 5]
    add shl + 4, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x08, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 4, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_5:
    add shr + 4, [rb + valx8], [ip + 5]
    add shl + 5, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x10, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 3, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_6:
    add shr + 3, [rb + valx8], [ip + 5]
    add shl + 6, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x20, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 2, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_7:
    add shr + 2, [rb + valx8], [ip + 5]
    add shl + 7, [rb + valx8], [ip + 2]
    add [0], [0], [rb + val]
    mul [flag_carry], 0x40, [rb + tmp]
    add [rb + val], [rb + tmp], [rb + val]

    add bits + 1, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_by_8:
    add shr + 1, [rb + valx8], [ip + 5]
    mul [flag_carry], 0x80, [rb + tmp]
    add [0], [rb + tmp], [rb + val]

    add bits + 0, [rb + valx8], [ip + 1]
    add [0], 0, [flag_carry]

    jz  0, [rb + overflow_algorithm]

execute_rcl_w_flags:
    # Update flags for rcl
    mul [rb + val], 8, [rb + valx8]

    add bits + 7, [rb + valx8], [ip + 1]
    eq  [0], [flag_carry], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

    jz  0, execute_rcl_rcr_w_store

execute_rcr_w_flags:
    # Update flags for rcr
    mul [rb + val], 8, [rb + valx8]

    add bits + 6, [rb + valx8], [ip + 5]
    add bits + 7, [rb + valx8], [ip + 2]
    eq  [0], [0], [flag_overflow]
    eq  [flag_overflow], 0, [flag_overflow]

execute_rcl_rcr_w_store:
    # Write the retated value
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_w

execute_rcl_rcr_w_done:
    arb 6
    ret 2
.ENDFRAME

.EOF
