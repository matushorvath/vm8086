.EXPORT arg_immediate_w
.EXPORT arg_ax_immediate_w
.EXPORT arg_bx_immediate_w
.EXPORT arg_cx_immediate_w
.EXPORT arg_dx_immediate_w
.EXPORT arg_sp_immediate_w
.EXPORT arg_bp_immediate_w
.EXPORT arg_si_immediate_w
.EXPORT arg_di_immediate_w

# From state.s
.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_dx
.IMPORT reg_sp
.IMPORT reg_bp
.IMPORT reg_si
.IMPORT reg_di
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip_w

# The first argument is an immediate 16-bit value, stored at cs:ip.
# The second argument is a 16-bit register.

##########
arg_immediate_w:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    mul [reg_cs + 1], 0x100, [rb + lseg]
    add [reg_cs + 0], [rb + lseg], [rb + lseg]
    mul [reg_ip + 1], 0x100, [rb + loff]
    add [reg_ip + 0], [rb + loff], [rb + loff]

    call inc_ip_w

    arb 2
    ret 0
.ENDFRAME

##########
arg_ax_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_ax + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bx_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_bx + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_cx_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_cx + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_dx_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_dx + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_sp_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_sp + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bp_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_bp + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_si_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_si + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_di_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    add 0x10000, 0, [rb + lseg_dst]
    add reg_di + 0, 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

.EOF
