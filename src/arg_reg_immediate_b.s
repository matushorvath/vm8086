.EXPORT arg_al_immediate_b
.EXPORT arg_bl_immediate_b
.EXPORT arg_cl_immediate_b
.EXPORT arg_dl_immediate_b
.EXPORT arg_ah_immediate_b
.EXPORT arg_bh_immediate_b
.EXPORT arg_ch_immediate_b
.EXPORT arg_dh_immediate_b

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT reg_al
.IMPORT reg_bl
.IMPORT reg_cl
.IMPORT reg_dl
.IMPORT reg_ah
.IMPORT reg_bh
.IMPORT reg_ch
.IMPORT reg_dh
.IMPORT inc_ip

# The first argument is an immediate 8-bit value, stored at cs:ip.
# The second argument is an 8-bit register.

##########
arg_al_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_al, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bl_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_bl, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_cl_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_cl, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_dl_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_dl, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_ah_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_ah, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_bh_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_bh, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_ch_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_ch, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_dh_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_src]

    call read_cs_ip_b
    add [rb - 2], 0, [rb + loc_addr_src]
    call inc_ip

    add 0, 0, [rb + loc_type_dst]
    add reg_dh, 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

.EOF
