.EXPORT arg_mod_000_rm_w
.EXPORT arg_mod_000_rm_immediate_b
.EXPORT arg_mod_000_rm_immediate_w

.EXPORT arg_mod_op_rm_b
.EXPORT arg_mod_op_rm_w
.EXPORT arg_mod_op_rm_b_immediate_b
.EXPORT arg_mod_op_rm_w_immediate_sxb
.EXPORT arg_mod_op_rm_w_immediate_w

# From arg_mod_reg_rm.s
.IMPORT arg_mod_rm_generic

# From util/error.s
.IMPORT report_error

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT inc_ip_b
.IMPORT inc_ip_w
.IMPORT reg_cs
.IMPORT reg_ip

##########
arg_mod_000_rm_w:
.FRAME lseg, loff                                           # returns lseg, loff
    arb -2

    # R/M is the parameter

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg]
    add [rb - 4], 0, [rb + loff]

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
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is dst, 8-bit immediate is src

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    # The REG field must be 0
    jnz [rb - 5], arg_mod_000_rm_immediate_b_nonzero_reg

    # Return pointer to 8-bit immediate
    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    arb 4
    ret 0

arg_mod_000_rm_immediate_b_nonzero_reg:
    add nonzero_reg_message, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
arg_mod_000_rm_immediate_w:
.FRAME lseg_src, loff_src, lseg_dst, loff_dst               # returns lseg_*, loff_*
    arb -4

    # R/M is dst, 16-bit immediate is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]

    # The REG field must be 0
    jnz [rb - 5], arg_mod_000_rm_immediate_w_nonzero_reg

    # Return pointer to 16-bit immediate
    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    arb 4
    ret 0

arg_mod_000_rm_immediate_w_nonzero_reg:
    add nonzero_reg_message, 0, [rb - 1]
    arb -1
    call report_error
.ENDFRAME

##########
arg_mod_op_rm_b:
.FRAME op, lseg, loff                                       # returns op, lseg, loff
    arb -3

    # R/M is the parameter

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg]
    add [rb - 4], 0, [rb + loff]
    add [rb - 5], 0, [rb + op]

    arb 3
    ret 0
.ENDFRAME

##########
arg_mod_op_rm_w:
.FRAME op, lseg, loff                                       # returns op, lseg, loff
    arb -3

    # R/M is the parameter

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg]
    add [rb - 4], 0, [rb + loff]
    add [rb - 5], 0, [rb + op]

    arb 3
    ret 0
.ENDFRAME

##########
arg_mod_op_rm_b_immediate_b:
.FRAME op, lseg_src, loff_src, lseg_dst, loff_dst           # returns op, lseg_*, loff_*
    arb -5

    # 8-bit R/M is dst, 8-bit immediate is src

    # Read and decode MOD and R/M
    add 0, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]
    add [rb - 5], 0, [rb + op]

    # Return pointer to 8-bit immediate
    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_b

    arb 5
    ret 0
.ENDFRAME

##########
arg_mod_op_rm_w_immediate_sxb:
.FRAME op, lseg_src, loff_src, lseg_dst, loff_dst, tmp      # returns op, lseg_*, loff_*
    arb -6

    # 16-bit R/M is dst, sign-extended 8-bit immediate is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]
    add [rb - 5], 0, [rb + op]

    # Retrieve the 8-bit immediate into the sign-extend buffer
    call read_cs_ip_b
    add [rb - 2], 0, [sign_extend_buffer_lo]
    call inc_ip_b

    # Sign extend the value
    lt  0x7f, [sign_extend_buffer_lo], [rb + tmp]
    mul [rb + tmp], 0xff, [sign_extend_buffer_hi]

    # Return pointer to the sign-extended 8-bit immediate in an intcode buffer
    add 0x10000, 0, [rb + lseg_src]
    add sign_extend_buffer_lo, 0, [rb + loff_src]

    arb 6
    ret 0
.ENDFRAME

##########
arg_mod_op_rm_w_immediate_w:
.FRAME op, lseg_src, loff_src, lseg_dst, loff_dst           # returns op, lseg_*, loff_*
    arb -5

    # 16-bit R/M is dst, 16-bit immediate is src

    # Read and decode MOD and R/M
    add 1, 0, [rb - 1]
    arb -1
    call arg_mod_rm_generic
    add [rb - 3], 0, [rb + lseg_dst]
    add [rb - 4], 0, [rb + loff_dst]
    add [rb - 5], 0, [rb + op]

    # Return pointer to 16-bit immediate
    mul [reg_cs + 1], 0x100, [rb + lseg_src]
    add [reg_cs + 0], [rb + lseg_src], [rb + lseg_src]
    mul [reg_ip + 1], 0x100, [rb + loff_src]
    add [reg_ip + 0], [rb + loff_src], [rb + loff_src]

    call inc_ip_w

    arb 5
    ret 0
.ENDFRAME

##########
nonzero_reg_message:
    db  "invalid non-zero REG value", 0

sign_extend_buffer_lo:
    db  0
sign_extend_buffer_hi:
    db  0

.EOF
