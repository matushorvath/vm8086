.EXPORT execute_mov_b
.EXPORT execute_mov_w

.EXPORT execute_xchg_b
.EXPORT execute_xchg_w
.EXPORT execute_xchg_ax_w

.EXPORT execute_cbw
.EXPORT execute_cwd

.EXPORT execute_xlat

# From the config file
.IMPORT config_log_cs_change

# From location.s
.IMPORT read_location_b
.IMPORT read_location_w
.IMPORT write_location_b
.IMPORT write_location_w

# From log.s
.IMPORT log_cs_change

# From memory.s
.IMPORT read_seg_off_b

# From prefix.s
.IMPORT ds_segment_prefix

# From state.s
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_dx
.IMPORT reg_cs

##########
execute_mov_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst;
    # Read the source value
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_b

    # Write the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b() -> param3
    arb -3
    call write_location_b

    ret 4
.ENDFRAME

##########
execute_mov_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst;
    # Read the source value
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_w

    # Write the destination value
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_w().lo -> param3
    add [rb - 5], 0, [rb - 4]                               # read_location_w().hi -> param4
    arb -4
    call write_location_w

    # Log CS change, if destination was reg_cs
    jz  [config_log_cs_change], execute_mov_w_after_log_cs_change

    eq  [rb + loff_dst], reg_cs, [rb - 1]
    jz  [rb - 1], execute_mov_w_after_log_cs_change

    eq  [rb + lseg_dst], 0x10000, [rb - 1]
    jz  [rb - 1], execute_mov_w_after_log_cs_change

    call log_cs_change

execute_mov_w_after_log_cs_change:
    ret 4
.ENDFRAME

##########
execute_xchg_b:
.FRAME lseg_1, loff_1, lseg_2, loff_2; value
    arb -1

    # Read the first value
    add [rb + lseg_1], 0, [rb - 1]
    add [rb + loff_1], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + value]

    # Read the second value
    add [rb + lseg_2], 0, [rb - 1]
    add [rb + loff_2], 0, [rb - 2]
    arb -2
    call read_location_b

    # Write the second value to first location
    add [rb + lseg_1], 0, [rb - 1]
    add [rb + loff_1], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_b() -> param3
    arb -3
    call write_location_b

    # Write the first value to second location
    add [rb + lseg_2], 0, [rb - 1]
    add [rb + loff_2], 0, [rb - 2]
    add [rb + value], 0, [rb - 3]
    arb -3
    call write_location_b

    arb 1
    ret 4
.ENDFRAME

##########
execute_xchg_w:
.FRAME lseg_1, loff_1, lseg_2, loff_2; value_lo, value_hi
    arb -2

    # Read the first value
    add [rb + lseg_1], 0, [rb - 1]
    add [rb + loff_1], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    # Read the second value
    add [rb + lseg_2], 0, [rb - 1]
    add [rb + loff_2], 0, [rb - 2]
    arb -2
    call read_location_w

    # Write the second value to first location
    add [rb + lseg_1], 0, [rb - 1]
    add [rb + loff_1], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]                               # read_location_w().lo -> param3
    add [rb - 5], 0, [rb - 4]                               # read_location_w().hi -> param4
    arb -4
    call write_location_w

    # Write the first value to second location
    add [rb + lseg_2], 0, [rb - 1]
    add [rb + loff_2], 0, [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    arb 2
    ret 4
.ENDFRAME

##########
execute_xchg_ax_w:
.FRAME lseg, loff;

    # Exchange AX with location
    add 0x10000, 0, [rb - 1]
    add reg_ax + 0, 0, [rb - 2]
    add [rb + lseg], 0, [rb - 3]
    add [rb + loff], 0, [rb - 4]
    arb -4
    call execute_xchg_w

    ret 2
.ENDFRAME

##########
execute_cbw:
.FRAME
    # Sign extend al into ah
    lt  0x7f, [reg_al], [reg_ah]
    mul [reg_ah], 0xff, [reg_ah]

    ret 0
.ENDFRAME

##########
execute_cwd:
.FRAME
    # Sign extend ax into dx
    lt  0x7f, [reg_ax + 1], [reg_dx + 0]
    mul [reg_dx + 0], 0xff, [reg_dx + 0]
    add [reg_dx + 0], 0, [reg_dx + 1]

    ret 0
.ENDFRAME

##########
execute_xlat:
.FRAME value_offset, tmp
    arb -2

    # Calculate address of the output value
    mul [reg_bx + 1], 0x100, [rb + value_offset]
    add [reg_bx + 0], [rb + value_offset], [rb + value_offset]
    add [reg_al], [rb + value_offset], [rb + value_offset]

    # Wrap around the offset
    lt  [rb + value_offset], 0x10000, [rb + tmp]
    jnz [rb + tmp], execute_xlat_no_overflow
    add [rb + value_offset], -0x10000, [rb + value_offset]

execute_xlat_no_overflow:
    # Read the value from memory to reg_al
    add [ds_segment_prefix], 1, [ip + 1]
    mul [0], 0x100, [rb - 1]
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], [rb - 1], [rb - 1]
    add [rb + value_offset], 0, [rb - 2]
    arb -2
    call read_seg_off_b
    add [rb - 4], 0, [reg_al]

    arb 2
    ret 0
.ENDFRAME

.EOF
