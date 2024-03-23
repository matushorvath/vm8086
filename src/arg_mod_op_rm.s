.EXPORT arg_mod_000_rm

.EXPORT arg_mod_000_rm_immediate_b
.EXPORT arg_mod_000_rm_immediate_w

.EXPORT arg_mod_op_rm_b_immediate_b
.EXPORT arg_mod_op_rm_w_immediate_b
.EXPORT arg_mod_op_rm_w_immediate_w

# From arg_mod_reg_rm.s
.IMPORT arg_mod_rm_generic

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT calc_cs_ip_addr

# From state.s
.IMPORT inc_ip

##########
arg_mod_000_rm:
.FRAME loc_type, loc_addr                                                       # returns loc_type_*, loc_addr_*
    arb -2

    # R/M is the parameter

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type]
    add [rb - 4], 0, [rb + loc_addr]

    # The REG field must be 0
    jnz [rb - 5], arg_mod_000_rm_nonzero_reg

    arb 2
    ret 0

arg_mod_000_rm_nonzero_reg:
    add nonzero_reg_message, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
arg_mod_000_rm_immediate_b:
.FRAME loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst                   # returns loc_type_*, loc_addr_*
    arb -4

    # R/M is dst, 8-bit immediate is src

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

    # R/M is dst, 16-bit immediate is src

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
arg_mod_op_rm_b_immediate_b:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst               # returns op, loc_type_*, loc_addr_*
    arb -5

    # 8-bit R/M is dst, 8-bit immediate is src

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]
    add [rb - 5], 0, [rb + op]

    # Return pointer to 8-bit immediate
    call calc_cs_ip_addr

    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]

    call inc_ip

    arb 5
    ret 0
.ENDFRAME

##########
arg_mod_op_rm_w_immediate_b:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst               # returns op, loc_type_*, loc_addr_*
    arb -4

    # 16-bit R/M is dst, 8-bit immediate is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]
    add [rb - 5], 0, [rb + op]

    # Return pointer to 8-bit immediate
    call calc_cs_ip_addr

    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]

    call inc_ip

    arb 4
    ret 0
.ENDFRAME

##########
arg_mod_op_rm_w_immediate_w:
.FRAME op, loc_type_src, loc_addr_src, loc_type_dst, loc_addr_dst               # returns op, loc_type_*, loc_addr_*
    arb -4

    # 16-bit R/M is dst, 16-bit immediate is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + loc_type_dst]
    add [rb - 4], 0, [rb + loc_addr_dst]
    add [rb - 5], 0, [rb + op]

    # Return pointer to 16-bit immediate
    call calc_cs_ip_addr

    add 1, 0, [rb + loc_type_src]
    add [rb - 2], 0, [rb + loc_addr_src]

    call inc_ip
    call inc_ip

    arb 4
    ret 0
.ENDFRAME

##########
nonzero_reg_message:
    db  "invalid non-zero REG value", 0

.EOF
