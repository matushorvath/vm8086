.EXPORT arg_al_ax_near_ptr_src
.EXPORT arg_al_ax_near_ptr_dst

# From memory.s
.IMPORT calc_addr
.IMPORT read_cs_ip_w

# From prefix.s
.IMPORT ds_segment_prefix

# From state.s
.IMPORT reg_al
.IMPORT reg_ax
.IMPORT inc_ip_w

# The first argument is an immediate 8-bit/16-bit value, stored at cs:ip.
# The second argument is either AL or AX.

##########
arg_al_ax_near_ptr_src:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # AL/AX is src, memory is dst

    call arg_al_ax_near_ptr_generic
    add [rb - 2], 0, [rb + loc_type_src]
    add [rb - 3], 0, [rb + loc_addr_src]
    add [rb - 4], 0, [rb + loc_type_dst]
    add [rb - 5], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_al_ax_near_ptr_dst:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # AL/AX is dst, memory is src

    call arg_al_ax_near_ptr_generic
    add [rb - 2], 0, [rb + loc_type_dst]
    add [rb - 3], 0, [rb + loc_addr_dst]
    add [rb - 4], 0, [rb + loc_type_src]
    add [rb - 5], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_al_ax_near_ptr_generic:
.FRAME loc_type_reg, loc_addr_reg, loc_type_mem, loc_addr_mem, off              # returns loc_type_*, loc_addr_*
    arb -5

    # Register location
    add 0, 0, [rb + loc_type_reg]
    add reg_al, 0, [rb + loc_addr_reg]

    # Read the immediate value, which is the offset part of a memory pointer to second location
    call read_cs_ip_w
    mul [rb - 3], 0x100, [rb + off]
    add [rb - 2], [rb + off], [rb + off]
    call inc_ip_w

    # Calculate physical address from DS:off
    add [ds_segment_prefix], 1, [ip + 1]
    mul [0], 0x100, [rb - 1]
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], [rb - 1], [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr

    # Memory location
    add 1, 0, [rb + loc_type_mem]
    add [rb - 4], 0, [rb + loc_addr_mem]

    arb 5
    ret 0
.ENDFRAME

.EOF
