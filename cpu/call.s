.EXPORT execute_call_near
.EXPORT execute_call_near_indirect
.EXPORT execute_call_far
.EXPORT execute_call_far_indirect

.EXPORT execute_ret_near_zero
.EXPORT execute_ret_near_immediate_w
.EXPORT execute_ret_far_zero
.EXPORT execute_ret_far_immediate_w

# From the config file
.IMPORT config_log_cs_change

# From location.s
.IMPORT read_location_w
.IMPORT read_location_dw

# From log_cs_change.s
.IMPORT log_cs_change

# From memory.s
.IMPORT read_cs_ip_w

# From stack.s
.IMPORT push_w
.IMPORT pop_w

# From state.s
.IMPORT reg_sp
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip_w

##########
execute_call_near:
.FRAME ptr_lo, ptr_hi, tmp
    arb -3

    # Read the near pointer
    call read_cs_ip_w
    add [rb - 2], 0, [rb + ptr_lo]
    add [rb - 3], 0, [rb + ptr_hi]
    call inc_ip_w

    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Add the 16-bit near pointer to the 16-bit reg_ip
    add [rb + ptr_lo], [reg_ip + 0], [reg_ip + 0]
    add [rb + ptr_hi], [reg_ip + 1], [reg_ip + 1]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_carry_lo

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

.after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_carry_hi

    add [reg_ip + 1], -0x100, [reg_ip + 1]

.after_carry_hi:
    arb 3
    ret 0
.ENDFRAME

##########
execute_call_near_indirect:
.FRAME lseg, loff; ip_lo, ip_hi
    arb -2

    # Read the far pointer; this needs to happen before we modify the stack,
    # in case stack overlaps the same lseg:loff location
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [rb + ip_lo]
    add [rb - 5], 0, [rb + ip_hi]

    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Update reg_ip
    add [rb + ip_lo], 0, [reg_ip + 0]
    add [rb + ip_hi], 0, [reg_ip + 1]

    arb 2
    ret 2
.ENDFRAME

##########
execute_call_far:
.FRAME offset_lo, offset_hi, segment_lo, segment_hi
    arb -4

    # Read the offset
    call read_cs_ip_w
    add [rb - 2], 0, [rb + offset_lo]
    add [rb - 3], 0, [rb + offset_hi]
    call inc_ip_w

    # Read the segment
    call read_cs_ip_w
    add [rb - 2], 0, [rb + segment_lo]
    add [rb - 3], 0, [rb + segment_hi]
    call inc_ip_w

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

    # Use the new values for cs:ip
    add [rb + segment_lo], 0, [reg_cs + 0]
    add [rb + segment_hi], 0, [reg_cs + 1]
    add [rb + offset_lo], 0, [reg_ip + 0]
    add [rb + offset_hi], 0, [reg_ip + 1]

    # Log CS change
    jz  [config_log_cs_change], .after_log_cs_change
    call log_cs_change

.after_log_cs_change:
    arb 4
    ret 0
.ENDFRAME

##########
execute_call_far_indirect:
.FRAME lseg, loff; cs_lo, cs_hi, ip_lo, ip_hi
    arb -4

    # Read the far pointer; this needs to happen before we modify the stack,
    # in case stack overlaps the same lseg:loff location
    # FF.3 e05f59d79804b51a8a9fa738597bc7528712b1e5
    add [rb + lseg], 0, [rb - 1]
    add [rb + loff], 0, [rb - 2]
    arb -2
    call read_location_dw
    add [rb - 4], 0, [rb + ip_lo]
    add [rb - 5], 0, [rb + ip_hi]
    add [rb - 6], 0, [rb + cs_lo]
    add [rb - 7], 0, [rb + cs_hi]

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

    # Update reg_cs and reg_ip
    add [rb + ip_lo], 0, [reg_ip + 0]
    add [rb + ip_hi], 0, [reg_ip + 1]
    add [rb + cs_lo], 0, [reg_cs + 0]
    add [rb + cs_hi], 0, [reg_cs + 1]

    # Log CS change
    jz  [config_log_cs_change], .after_log_cs
    call log_cs_change

.after_log_cs:
    arb 4
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

    # Load the immediate value before we update IP
    call read_cs_ip_w
    add [rb - 2], 0, [rb + data_lo]
    add [rb - 3], 0, [rb + data_hi]

    # Pop new IP value
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    # Add the 16-bit immediate to the 16-bit reg_sp
    add [rb + data_lo], [reg_sp + 0], [reg_sp + 0]
    add [rb + data_hi], [reg_sp + 1], [reg_sp + 1]

    # Check for carry out of low byte
    lt  [reg_sp + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_carry_lo

    add [reg_sp + 0], -0x100, [reg_sp + 0]
    add [reg_sp + 1], 1, [reg_sp + 1]

.after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_sp + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_carry_hi

    add [reg_sp + 1], -0x100, [reg_sp + 1]

.after_carry_hi:
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

    # Log CS change
    jz  [config_log_cs_change], .after_log_cs_change
    call log_cs_change

.after_log_cs_change:
    ret 0
.ENDFRAME

##########
execute_ret_far_immediate_w:
.FRAME data_lo, data_hi, tmp
    arb -3

    # Load the immediate value before we update CS and IP
    call read_cs_ip_w
    add [rb - 2], 0, [rb + data_lo]
    add [rb - 3], 0, [rb + data_hi]

    # Pop IP
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    # Pop CS
    call pop_w
    add [rb - 2], 0, [reg_cs + 0]
    add [rb - 3], 0, [reg_cs + 1]

    # Add the 16-bit immediate to the 16-bit reg_sp
    add [rb + data_lo], [reg_sp + 0], [reg_sp + 0]
    add [rb + data_hi], [reg_sp + 1], [reg_sp + 1]

    # Check for carry out of low byte
    lt  [reg_sp + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_carry_lo

    add [reg_sp + 0], -0x100, [reg_sp + 0]
    add [reg_sp + 1], 1, [reg_sp + 1]

.after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_sp + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_carry_hi

    add [reg_sp + 1], -0x100, [reg_sp + 1]

.after_carry_hi:
    # Log CS change
    jz  [config_log_cs_change], .after_log_cs
    call log_cs_change

.after_log_cs:
    arb 3
    ret 0
.ENDFRAME

.EOF
