.EXPORT execute_jmp_short
.EXPORT execute_jmp_near
.EXPORT execute_jmp_near_indirect
.EXPORT execute_jmp_far
.EXPORT execute_jmp_far_indirect

# From location.s
.IMPORT read_location_w
.IMPORT read_location_dw

# From memory.s
.IMPORT read_cs_ip_b
.IMPORT read_cs_ip_w

.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip_b
.IMPORT inc_ip_w

##########
execute_jmp_short:
.FRAME ptr, tmp
    arb -2

    # Read the short pointer
    call read_cs_ip_b
    add [rb - 2], 0, [rb + ptr]
    call inc_ip_b

    # Calculate sign extension of ptr
    lt  0x7f, [rb + ptr], [rb + tmp]
    mul [rb + tmp], 0xff, [rb + tmp]

    # Add the sign-extended 8-bit short pointer to the 16-bit reg_ip
    add [rb + ptr], [reg_ip + 0], [reg_ip + 0]
    add [rb + tmp], [reg_ip + 1], [reg_ip + 1]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jmp_short_after_carry_lo

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

execute_jmp_short_after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jmp_short_after_carry_hi

    add [reg_ip + 1], -0x100, [reg_ip + 1]

execute_jmp_short_after_carry_hi:
    arb 2
    ret 0
.ENDFRAME

##########
execute_jmp_near:
.FRAME ptr_lo, ptr_hi, tmp
    arb -3

    # Read the near pointer
    call read_cs_ip_w
    add [rb - 2], 0, [rb + ptr_lo]
    add [rb - 3], 0, [rb + ptr_hi]
    call inc_ip_w

    # Add the 16-bit near pointer to the 16-bit reg_ip
    add [rb + ptr_lo], [reg_ip + 0], [reg_ip + 0]
    add [rb + ptr_hi], [reg_ip + 1], [reg_ip + 1]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jmp_near_after_carry_lo

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

execute_jmp_near_after_carry_lo:
    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jmp_near_after_carry_hi

    add [reg_ip + 1], -0x100, [reg_ip + 1]

execute_jmp_near_after_carry_hi:
    arb 3
    ret 0
.ENDFRAME

##########
execute_jmp_near_indirect:
.FRAME loc_type, loc_addr;
    # Read the near pointer into reg_ip
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_w
    add [rb - 4], 0, [reg_ip + 0]
    add [rb - 5], 0, [reg_ip + 1]

    ret 2
.ENDFRAME

##########
execute_jmp_far:
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

    # Use the new values for cs:ip
    add [rb + segment_lo], 0, [reg_cs + 0]
    add [rb + segment_hi], 0, [reg_cs + 1]
    add [rb + offset_lo], 0, [reg_ip + 0]
    add [rb + offset_hi], 0, [reg_ip + 1]

    arb 4
    ret 0
.ENDFRAME

##########
execute_jmp_far_indirect:
.FRAME loc_type, loc_addr;
    # Read the far pointer into reg_cs and reg_ip
    add [rb + loc_type], 0, [rb - 1]
    add [rb + loc_addr], 0, [rb - 2]
    arb -2
    call read_location_dw
    add [rb - 4], 0, [reg_ip + 0]
    add [rb - 5], 0, [reg_ip + 1]
    add [rb - 6], 0, [reg_cs + 0]
    add [rb - 7], 0, [reg_cs + 1]

    ret 2
.ENDFRAME

.EOF
