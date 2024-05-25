.EXPORT arg_immediate_b
.EXPORT arg_al_immediate_b
.EXPORT arg_bl_immediate_b
.EXPORT arg_cl_immediate_b
.EXPORT arg_dl_immediate_b
.EXPORT arg_ah_immediate_b
.EXPORT arg_bh_immediate_b
.EXPORT arg_ch_immediate_b
.EXPORT arg_dh_immediate_b

# From state.s
.IMPORT reg_al
.IMPORT reg_bl
.IMPORT reg_cl
.IMPORT reg_dl
.IMPORT reg_ah
.IMPORT reg_bh
.IMPORT reg_ch
.IMPORT reg_dh
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip_b

# The first argument is an immediate 8-bit value, stored at cs:ip.
# The second argument is an 8-bit register.

##########
arg_immediate_b:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    mul [reg_cs + 1], 0x100, [rb + lseg]
    add [reg_cs + 0], [rb + lseg], [rb + lseg]
    mul [reg_ip + 1], 0x100, [rb + loff]
    add [reg_ip + 0], [rb + loff], [rb + loff]

    call inc_ip_b

    arb 2
    ret 0
.ENDFRAME

##########
arg_al_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_al, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bl_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_bl, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_cl_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_cl, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_dl_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_dl, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_ah_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_ah, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bh_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_bh, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_ch_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_ch, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_dh_immediate_b:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    add 0x10000, 0, [rb + lseg_dst]
    add reg_dh, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

.EOF
