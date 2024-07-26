.EXPORT execute_lea
.EXPORT execute_lds
.EXPORT execute_les

# From decode.s
.IMPORT decode_mod_rm
.IMPORT decode_reg

# From util/error.s
.IMPORT report_error

# From location.s
.IMPORT read_location_dw
.IMPORT write_location_w

# From memory.s
.IMPORT read_cs_ip_b

# From util/split233.s
.IMPORT split233_0
.IMPORT split233_1
.IMPORT split233_2

# From state.s
.IMPORT reg_ds
.IMPORT reg_es
.IMPORT inc_ip_b

##########
execute_lea:
.FRAME mod, reg, rm, regptr, off_lo, off_hi, tmp
    arb -7

    # Read the MOD REG R/M byte and split it
    call read_cs_ip_b
    add [rb - 2], 0, [rb + tmp]
    call inc_ip_b

    add split233_0, [rb + tmp], [ip + 1]
    add [0], 0, [rb + rm]
    add split233_1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + reg]
    add split233_2, [rb + tmp], [ip + 1]
    add [0], 0, [rb + mod]

    # Decode MOD and R/M
    add [rb + mod], 0, [rb - 1]
    add [rb + rm], 0, [rb - 2]
    add 1, 0, [rb - 3]
    arb -3
    call decode_mod_rm
    add [rb - 8], 0, [rb + off_lo]
    add [rb - 9], 0, [rb + off_hi]

    # Is this an 8086 register, or 8086 memory?
    jz  [rb - 5], .memory

    # It's a register, that is not supported
    add .register_message, 0, [rb - 1]
    arb -1
    call report_error

.memory:
    # Decode REG
    add [rb + reg], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call decode_reg
    add [rb - 4], 0, [rb + regptr]

    # Write effective address of the memory into the register
    add [rb + regptr], 0, [ip + 3]
    add [rb + off_lo], 0, [0]
    add [rb + regptr], 1, [ip + 3]
    add [rb + off_hi], 0, [0]

    arb 7
    ret 0

.register_message:
    db  "cannot load effective address of a register", 0
.ENDFRAME

##########
execute_lds:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; seg_lo, seg_hi, off_lo, off_hi
    arb -4

    # Read the far pointer from source
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_dw
    add [rb - 4], 0, [rb + off_lo]
    add [rb - 5], 0, [rb + off_hi]
    add [rb - 6], 0, [rb + seg_lo]
    add [rb - 7], 0, [rb + seg_hi]

    # Save the offset into the destination
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + off_lo], 0, [rb - 3]
    add [rb + off_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    # Save the segment into DS
    add [rb + seg_lo], 0, [reg_ds + 0]
    add [rb + seg_hi], 0, [reg_ds + 1]

    arb 4
    ret 4
.ENDFRAME

##########
execute_les:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst; seg_lo, seg_hi, off_lo, off_hi
    arb -4

    # Read the far pointer from source
    add [rb + lseg_src], 0, [rb - 1]
    add [rb + loff_src], 0, [rb - 2]
    arb -2
    call read_location_dw
    add [rb - 4], 0, [rb + off_lo]
    add [rb - 5], 0, [rb + off_hi]
    add [rb - 6], 0, [rb + seg_lo]
    add [rb - 7], 0, [rb + seg_hi]

    # Save the offset into the destination
    add [rb + lseg_dst], 0, [rb - 1]
    add [rb + loff_dst], 0, [rb - 2]
    add [rb + off_lo], 0, [rb - 3]
    add [rb + off_hi], 0, [rb - 4]
    arb -4
    call write_location_w

    # Save the segment into ES
    add [rb + seg_lo], 0, [reg_es + 0]
    add [rb + seg_hi], 0, [reg_es + 1]

    arb 4
    ret 4
.ENDFRAME

.EOF
