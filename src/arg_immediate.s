.EXPORT arg_immediate_b
.EXPORT arg_immediate_w
.EXPORT arg_two_immediate_w

# From memory.s
.IMPORT calc_cs_ip_addr

# From state.s
.IMPORT inc_ip

##########
arg_immediate_b:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 1, 0, [rb + loc_type]

    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + loc_addr]
    call inc_ip

    arb 2
    ret 0
.ENDFRAME

##########
arg_immediate_w:
.FRAME loc_type, loc_addr                                   # returns loc_type, loc_addr
    arb -2

    add 1, 0, [rb + loc_type]

    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + loc_addr]

    call inc_ip
    call inc_ip

    arb 2
    ret 0
.ENDFRAME

##########
arg_two_immediate_w:
.FRAME loc_type_1, loc_addr_1, loc_type_2, loc_addr_2       # returns loc_type_*, loc_addr_*
    arb -4

    add 1, 0, [rb + loc_type_1]
    add 1, 0, [rb + loc_type_2]

    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + loc_addr_1]

    call inc_ip
    call inc_ip

    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + loc_addr_2]

    call inc_ip
    call inc_ip

    arb 4
    ret 0
.ENDFRAME

.EOF
