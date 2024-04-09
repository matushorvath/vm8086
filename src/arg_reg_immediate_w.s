.EXPORT arg_immediate_w
.EXPORT arg_ax_immediate_w
.EXPORT arg_bx_immediate_w
.EXPORT arg_cx_immediate_w
.EXPORT arg_dx_immediate_w
.EXPORT arg_sp_immediate_w
.EXPORT arg_bp_immediate_w
.EXPORT arg_si_immediate_w
.EXPORT arg_di_immediate_w

# From memory.s
.IMPORT calc_cs_ip_addr

# From state.s
.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_dx
.IMPORT reg_sp
.IMPORT reg_bp
.IMPORT reg_si
.IMPORT reg_di
.IMPORT inc_ip_w

# The first argument is an immediate 16-bit value, stored at cs:ip.
# The second argument is a 16-bit register.

##########
arg_immediate_w:
.FRAME loc_type, loc_addr                                                       # returns loc_type, loc_addr
    arb -2

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type]
    add [rb - 2], 0, [rb + loc_addr]
    call inc_ip_w

    arb 2
    ret 0
.ENDFRAME

##########
arg_ax_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_ax + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bx_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_bx + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_cx_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_cx + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_dx_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_dx + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_sp_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_sp + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bp_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_bp + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_si_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_si + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_di_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    call calc_cs_ip_addr
    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip_w

    add 0, 0, [rb + loc_type_dst]
    add reg_di + 0, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

.EOF
