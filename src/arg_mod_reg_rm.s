.EXPORT arg_mod_reg_rm_src_b
.EXPORT arg_mod_reg_rm_src_w
.EXPORT arg_mod_reg_rm_dst_b
.EXPORT arg_mod_reg_rm_dst_w

.EXPORT arg_mod_1sr_rm_src
.EXPORT arg_mod_1sr_rm_dst

.EXPORT arg_mod_000_rm_immediate_b
.EXPORT arg_mod_000_rm_immediate_w

# From decode.s
.IMPORT decode_mod_rm
.IMPORT decode_reg
.IMPORT decode_sr

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT calc_cs_ip_addr
.IMPORT read_cs_ip_b

# From split233.s
.IMPORT split233

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip

# "_src_" means the REG field is the source
# "_dst_" means the REG field is the destination

##########
arg_mod_reg_rm_src_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is dst, REG is src

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
    add [rb - 4], 0, [rb + loc_type_src]
    add [rb - 5], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_src_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is dst, REG is src

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
    add [rb - 4], 0, [rb + loc_type_src]
    add [rb - 5], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_dst_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is src, REG is dst

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
    add [rb - 4], 0, [rb + loc_type_dst]
    add [rb - 5], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_reg_rm_dst_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is src, REG is dst

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
    add [rb - 4], 0, [rb + loc_type_dst]
    add [rb - 5], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_1sr_rm_src:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is dst, SR is src

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
    add [rb - 3], 0, [rb + loc_type_src]
    add [rb - 4], 0, [rb + loc_addr_src]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_1sr_rm_dst:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is src, SR is dst

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
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_000_rm_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is dst, 8-bit immediate is src

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    # The REG field must be 0
    jnz [rb - 5], arg_mod_000_rm_immediate_b_nonzero_reg

    # Return pointer to 8-bit immediate
    call calc_cs_ip_addr

    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]

    call inc_ip

    arb 4
    ret 0

arg_mod_000_rm_immediate_b_nonzero_reg:
    add nonzero_reg_message, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
arg_mod_000_rm_immediate_w:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # RM is dst, 8-bit immediate is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]

    # The REG field must be 0
    jnz [rb - 5], arg_mod_000_rm_immediate_w_nonzero_reg

    # Return pointer to 16-bit immediate
    call calc_cs_ip_addr

    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]

    call inc_ip
    call inc_ip

    arb 4
    ret 0

arg_mod_000_rm_immediate_w_nonzero_reg:
    add nonzero_reg_message, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
nonzero_reg_message:
    db  "invalid non-zero REG value", 0

##########
arg_mod_rm_generic:
.FRAME w; loc_type_rm, loc_addr_rm, reg, mod, rm, tmp                           # returns loc_type_rm, loc_addr_rm, reg
    arb -6

    # Read the MOD REG R/M byte and split it
    call read_cs_ip_b
    add [rb - 2], 0, [rb + tmp]
    call inc_ip

    mul [rb + tmp], 3, [rb + tmp]
    add split233 + 0, [rb + tmp], [ip + 1]
    add [0], 0, [rb + rm]
    add split233 + 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + reg]
    add split233 + 2, [rb + tmp], [ip + 1]
    add [0], 0, [rb + mod]

    # Decode MOD and RM
    add [rb + mod], 0, [rb - 1]
    add [rb + rm], 0, [rb - 2]
    add [rb + w], 0, [rb - 3]
    arb -3
    call decode_mod_rm
    add [rb - 5], 0, [rb + loc_type_rm]
    add [rb - 6], 0, [rb + loc_addr_rm]

    arb 6
    ret 1
.ENDFRAME

.EOF
