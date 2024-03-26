.EXPORT execute_call_near
.EXPORT execute_call_near_indirect
.EXPORT execute_call_far
.EXPORT execute_call_far_indirect

.EXPORT execute_ret_near_zero
.EXPORT execute_ret_near_immediate_w
.EXPORT execute_ret_far_zero
.EXPORT execute_ret_far_immediate_w

# From error.s
.IMPORT report_error

# From jump.s
.IMPORT execute_jmp_near
.IMPORT execute_jmp_near_indirect
.IMPORT execute_jmp_far
.IMPORT execute_jmp_far_indirect

# From memory.s
.IMPORT read_cs_ip_w

# From stack.s
.IMPORT push_w
.IMPORT pop_w

# From state.s
.IMPORT reg_sp
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip

##########
execute_call_near:
.FRAME
    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Jump
    call execute_jmp_near

    ret 0
.ENDFRAME

##########
execute_call_near_indirect:
.FRAME loc_type, loc_addr;
    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Jump
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 1]
    arb -2
    call execute_jmp_near

    ret 2
.ENDFRAME

##########
execute_call_far:
.FRAME
    # Push CS
    add [reg_cs + 0], 0, [rb - 1]
    add [reg_cs + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Jump
    call execute_jmp_far

    ret 0
.ENDFRAME

##########
execute_call_far_indirect:
.FRAME loc_type_offset, loc_addr_offset;
    # Push CS
    add [reg_cs + 0], 0, [rb - 1]
    add [reg_cs + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Jump
    add [rb + loc_type_offset], 0, [rb - 1]
    add [rb + loc_addr_offset], 0, [rb - 1]
    arb -2
    call execute_jmp_far

    ret 2
.ENDFRAME

##########
execute_ret_near_zero:
.FRAME
    # Pop IP
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    ret 0
.ENDFRAME

##########
execute_ret_near_immediate_w:
.FRAME data_lo, data_hi, tmp
    arb -3

    # Pop IP
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    # Increment SP by an immediate value
    call read_cs_ip_w
    add [rb - 2], 0, [rb + data_lo]
    add [rb - 3], 0, [rb + data_hi]

    call inc_ip
    call inc_ip

    # Add the 16-bit immediate to the 16-bit reg_sp
    add [rb + data_lo], [reg_sp + 0], [reg_sp + 0]
    add [rb + data_hi], [reg_sp + 1], [reg_sp + 1]

    # Check for carry out of low byte
    lt [reg_sp + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_ret_near_immediate_w_after_carry_lo

    add [reg_sp + 0], -0x100, [reg_sp + 0]
    add [reg_sp + 1], 1, [reg_sp + 1]

execute_ret_near_immediate_w_after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_sp + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_ret_near_immediate_w_after_carry_hi

    add [reg_sp + 1], -0x100, [reg_sp + 1]

execute_ret_near_immediate_w_after_carry_hi:
    arb 3
    ret 0
.ENDFRAME

##########
execute_ret_far_zero:
.FRAME
    # Pop IP
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    # Pop CS
    call pop_w
    add [rb - 2], 0, [reg_cs + 0]
    add [rb - 3], 0, [reg_cs + 1]

    ret 0
.ENDFRAME

##########
execute_ret_far_immediate_w:
.FRAME data_lo, data_hi, tmp
    arb -3

    # Pop IP
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    # Pop CS
    call pop_w
    add [rb - 2], 0, [reg_cs + 0]
    add [rb - 3], 0, [reg_cs + 1]

    # Increment SP by an immediate value
    call read_cs_ip_w
    add [rb - 2], 0, [rb + data_lo]
    add [rb - 3], 0, [rb + data_hi]

    call inc_ip
    call inc_ip

    # Add the 16-bit immediate to the 16-bit reg_sp
    add [rb + data_lo], [reg_sp + 0], [reg_sp + 0]
    add [rb + data_hi], [reg_sp + 1], [reg_sp + 1]

    # Check for carry out of low byte
    lt [reg_sp + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_ret_far_immediate_w_after_carry_lo

    add [reg_sp + 0], -0x100, [reg_sp + 0]
    add [reg_sp + 1], 1, [reg_sp + 1]

execute_ret_far_immediate_w_after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_sp + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_ret_far_immediate_w_after_carry_hi

    add [reg_sp + 1], -0x100, [reg_sp + 1]

execute_ret_far_immediate_w_after_carry_hi:
    arb 3
    ret 0
.ENDFRAME

.EOF
