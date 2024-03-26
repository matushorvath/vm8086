.EXPORT execute_jmp_short
.EXPORT execute_jmp_near
.EXPORT execute_jmp_near_indirect
.EXPORT execute_jmp_far
.EXPORT execute_jmp_far_indirect

# From error.s
.IMPORT report_error

# From location.s
.IMPORT read_location_w

# From memory.s
.IMPORT read_cs_ip_b
.IMPORT read_cs_ip_w
.IMPORT read_w

.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip

##########
execute_jmp_short:
.FRAME ptr, tmp
    arb -2

    # Read the short pointer
    call read_cs_ip_b
    add [rb - 2], 0, [rb + ptr]
    call inc_ip

    # Calculate sign extension of ptr
    lt  0x7f, [rb + ptr], [rb + tmp]
    mul [rb + tmp], 0xff, [rb + tmp]

    # Add the sign-extended 8-bit short pointer to the 16-bit reg_ip
    add [rb + ptr], [reg_ip + 0], [reg_ip + 0]
    add [rb + tmp], [reg_ip + 1], [reg_ip + 1]

    # Check for carry out of low byte
    lt [reg_ip + 0], 0x100, [rb + tmp]
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

    call inc_ip
    call inc_ip

    # Add the 16-bit near pointer to the 16-bit reg_ip
    add [rb + ptr_lo], [reg_ip + 0], [reg_ip + 0]
    add [rb + ptr_hi], [reg_ip + 1], [reg_ip + 1]

    # Check for carry out of low byte
    lt [reg_ip + 0], 0x100, [rb + tmp]
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
.FRAME offset_lo, offset_hi, segment_lo, segment_hi, tmp
    arb -5

    # Read the offset
    call read_cs_ip_w
    add [rb - 2], 0, [rb + offset_lo]
    add [rb - 3], 0, [rb + offset_hi]

    call inc_ip
    call inc_ip

    # Read the segment
    call read_cs_ip_w
    add [rb - 2], 0, [rb + segment_lo]
    add [rb - 3], 0, [rb + segment_hi]

    call inc_ip
    call inc_ip

    # Use the new values for cs:ip
    add [rb + segment_lo], 0, [reg_cs + 0]
    add [rb + segment_hi], 0, [reg_cs + 1]
    add [rb + offset_lo], 0, [reg_ip + 0]
    add [rb + offset_hi], 0, [reg_ip + 1]

    arb 5
    ret 0
.ENDFRAME

##########
execute_jmp_far_indirect:
.FRAME loc_type_offset, loc_addr_offset; loc_addr_segment, tmp
    arb -2

    # The location we received must be a 8086 memory location, and it contains the offset.
    # After that we expect two more bytes to contain the segment.

    # Verify that the offset location is 8086 memory
    eq  [rb + loc_type_offset], 1, [rb + tmp]
    jnz [rb + loc_type_offset], execute_jmp_far_indirect_is_memory

    add execute_jmp_far_indirect_not_memory_message, 0, [rb - 1]
    arb -1
    call report_error

execute_jmp_far_indirect_is_memory:
    # Calculate address of two bytes after given location, which contain the target segment
    add [rb + loc_addr_offset], 2, [rb + loc_addr_segment]

    # Wrap around to 16 bits
    lt  [rb + loc_addr_segment], 0x10000, [rb + tmp]
    jnz [rb + tmp], execute_group2_w_jmp_far_after_carry

    add [rb + loc_addr_segment], -0x10000, [rb + loc_addr_segment]

execute_group2_w_jmp_far_after_carry:
    # Read the offset from given location (we know it's 8086 memory) into reg_ip
    add [rb + loc_addr_offset], 0, [rb - 1]
    arb -1
    call read_w
    add [rb - 3], 0, [reg_ip + 0]
    add [rb - 4], 0, [reg_ip + 1]

    # Read the segment from the address we calculated into reg_cs
    add [rb + loc_addr_segment], 0, [rb - 1]
    arb -1
    call read_w
    add [rb - 3], 0, [reg_cs + 0]
    add [rb - 4], 0, [reg_cs + 1]

    arb 2
    ret 2

##########
execute_jmp_far_indirect_not_memory_message:
    db  "invalid argment for indirect far jump/call", 0
.ENDFRAME

.EOF
