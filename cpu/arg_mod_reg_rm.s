.EXPORT arg_mod_reg_rm_src_b
.EXPORT arg_mod_reg_rm_src_w
.EXPORT arg_mod_reg_rm_dst_b
.EXPORT arg_mod_reg_rm_dst_w

.EXPORT arg_mod_1sr_rm_src
.EXPORT arg_mod_1sr_rm_dst

.EXPORT arg_mod_rm_generic

# From decode.s
.IMPORT decode_mod_rm
.IMPORT decode_reg
.IMPORT decode_sr

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT inc_ip_b

# From util/split233.s
.IMPORT split233_0
.IMPORT split233_1
.IMPORT split233_2

# "_src_" means the REG field is the source
# "_dst_" means the REG field is the destination

##########
arg_mod_reg_rm_src_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is dst, REG is src

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0x10000, 0, [rb + lseg_src]
    add [rb - 4], 0, [rb + loff_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_src_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is dst, REG is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0x10000, 0, [rb + lseg_src]
    add [rb - 4], 0, [rb + loff_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_dst_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is src, REG is dst

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_src]
    add [rb - 4], 0, [rb + loff_src]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0x10000, 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_dst_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is src, REG is dst

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_src]
    add [rb - 4], 0, [rb + loff_src]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0x10000, 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_1sr_rm_src:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is dst, SR is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    # Decode SR
    add [rb - 5], 0, [rb - 1]
    arb -1
    call decode_sr
    add 0x10000, 0, [rb + lseg_src]
    add [rb - 3], 0, [rb + loff_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_1sr_rm_dst:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is src, SR is dst

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_src]
    add [rb - 4], 0, [rb + loff_src]

    # Decode SR
    add [rb - 5], 0, [rb - 1]
    arb -1
    call decode_sr
    add 0x10000, 0, [rb + lseg_dst]
    add [rb - 3], 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_rm_generic:
.FRAME w; lseg_rm, loff_rm, reg, mod, rm, tmp               # returns lseg_rm, loff_rm, reg
    arb -6

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
    add [rb + w], 0, [rb - 3]
    arb -3
    call decode_mod_rm

    # Is this an 8086 register or 8086 memory?
    jnz [rb - 5], .register

    # It's 8086 memory, return segment and offset
    mul [rb - 7], 0x100, [rb + lseg_rm]
    add [rb - 6], [rb + lseg_rm], [rb + lseg_rm]
    mul [rb - 9], 0x100, [rb + loff_rm]
    add [rb - 8], [rb + loff_rm], [rb + loff_rm]

    jz  0, .done

.register:
    # It's an 8086 register
    add 0x10000, 0, [rb + lseg_rm]
    add [rb - 5], 0, [rb + loff_rm]

.done:
    arb 6
    ret 1
.ENDFRAME

.EOF
