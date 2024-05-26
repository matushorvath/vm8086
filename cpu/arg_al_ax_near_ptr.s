.EXPORT arg_al_ax_near_ptr_src
.EXPORT arg_al_ax_near_ptr_dst

# From memory.s
.IMPORT read_cs_ip_w

# From prefix.s
.IMPORT ds_segment_prefix

# From state.s
.IMPORT reg_al
.IMPORT inc_ip_w

# The first argument is an immediate 8-bit/16-bit value, stored at cs:ip.
# The second argument is either AL or AX.

##########
arg_al_ax_near_ptr_src:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # AL/AX is src, memory is dst

    call arg_al_ax_near_ptr_generic
    add [rb - 2], 0, [rb + lseg_src]
    add [rb - 3], 0, [rb + loff_src]
    add [rb - 4], 0, [rb + lseg_dst]
    add [rb - 5], 0, [rb + loff_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_al_ax_near_ptr_dst:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # AL/AX is dst, memory is src

    call arg_al_ax_near_ptr_generic
    add [rb - 2], 0, [rb + lseg_dst]
    add [rb - 3], 0, [rb + loff_dst]
    add [rb - 4], 0, [rb + lseg_src]
    add [rb - 5], 0, [rb + loff_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_al_ax_near_ptr_generic:
.FRAME lseg_reg, loff_reg, lseg_mem, loff_mem               # returns lseg_*, loff_*
    arb -4

    # Register location
    add 0x10000, 0, [rb + lseg_reg]
    add reg_al, 0, [rb + loff_reg]

    # Memory location, segment is DS
    add [ds_segment_prefix], 1, [ip + 1]
    mul [0], 0x100, [rb + lseg_mem]
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], [rb + lseg_mem], [rb + lseg_mem]

    # Memory location, offset is the immediate value
    call read_cs_ip_w
    mul [rb - 3], 0x100, [rb + loff_mem]
    add [rb - 2], [rb + loff_mem], [rb + loff_mem]
    call inc_ip_w

    arb 4
    ret 0
.ENDFRAME

.EOF
