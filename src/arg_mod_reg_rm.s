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

# From obj/split233.s
.IMPORT split233

# From state.s
.IMPORT inc_ip_b

# "_src_" means the REG field is the source
# "_dst_" means the REG field is the destination

##########
arg_mod_reg_rm_src_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is dst, REG is src

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0, 0, [rb + loc_type_src]
    add [rb - 4], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_src_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is dst, REG is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0, 0, [rb + loc_type_src]
    add [rb - 4], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_dst_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is src, REG is dst

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_src]
    add [rb - 4], 0, [rb + loc_addr_src]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 0, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0, 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_dst_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is src, REG is dst

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_src]
    add [rb - 4], 0, [rb + loc_addr_src]

    # Decode REG
    add [rb - 5], 0, [rb - 1]
    add 1, 0, [rb - 2]
    arb -2
    call decode_reg
    add 0, 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_1sr_rm_src:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is dst, SR is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    # Decode SR
    add [rb - 5], 0, [rb - 1]
    arb -1
    call decode_sr
    add 0, 0, [rb + loc_type_src]
    add [rb - 3], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_1sr_rm_dst:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is src, SR is dst

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_src]
    add [rb - 4], 0, [rb + loc_addr_src]

    # Decode SR
    add [rb - 5], 0, [rb - 1]
    arb -1
    call decode_sr
    add 0, 0, [rb + loc_type_dst]
    add [rb - 3], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_rm_generic:
.FRAME w; loc_type_rm, loc_addr_rm, reg, mod, rm, tmp                           # returns loc_type_rm, loc_addr_rm, reg
    arb -6

    # Read the MOD REG R/M byte and split it
    call read_cs_ip_b
    add [rb - 2], 0, [rb + tmp]
    call inc_ip_b

    mul [rb + tmp], 3, [rb + tmp]
    add split233 + 0, [rb + tmp], [ip + 1]
    add [0], 0, [rb + rm]
    add split233 + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + reg]
    add split233 + 2, [rb + tmp], [ip + 1]
    add [0], 0, [rb + mod]

    # Decode MOD and R/M
    add [rb + mod], 0, [rb - 1]
    add [rb + rm], 0, [rb - 2]
    add [rb + w], 0, [rb - 3]
    arb -3
    call decode_mod_rm

    # Is this an 8086 register or 8086 memory?
    jnz [rb - 5], arg_mod_rm_generic_register

    # It's 8086 memory
    add 1, 0, [rb + loc_type_rm]

    # loc_addr_rm = (seg << 4) + off
    #
    #       3210|7654 3210|7654 3210
    # seg = ---sgh--- ---sgl---
    # off =      ---ofh--- ---ofl---
    #
    # loc_addr_rm = (((sgh << 4) + ofh) << 4 + sgl) << 4 + ofl;
    #
    # seg is [rb - 6], [rb - 7]
    # off is [rb - 8], [rb - 9]
    #
    # loc_addr_rm = ((([rb - 7] << 4) + [rb - 9]) << 4 + [rb - 6]) << 4 + [rb - 8];

    mul [rb - 7], 0x10, [rb + loc_addr_rm]
    add [rb - 9], [rb + loc_addr_rm], [rb + loc_addr_rm]
    mul [rb + loc_addr_rm], 0x10, [rb + loc_addr_rm]
    add [rb - 6], [rb + loc_addr_rm], [rb + loc_addr_rm]
    mul [rb + loc_addr_rm], 0x10, [rb + loc_addr_rm]
    add [rb - 8], [rb + loc_addr_rm], [rb + loc_addr_rm]

    # TODO loc_addr_rm should wrap around to 20 bits

    jz  0, arg_mod_rm_generic_done

arg_mod_rm_generic_register:
    # It's an 8086 register
    add 0, 0, [rb + loc_type_rm]
    add [rb - 5], 0, [rb + loc_addr_rm]

arg_mod_rm_generic_done:
    arb 6
    ret 1
.ENDFRAME

.EOF
