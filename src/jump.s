.EXPORT execute_jo

# From memory.s
.IMPORT read_cs_ip_b

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow
.IMPORT flag_interrupt
.IMPORT flag_direction
.IMPORT flag_trap

.IMPORT reg_ip
.IMPORT inc_ip

##########
execute_jo:
.FRAME ptr, tmp
    arb -2

    jnz [flag_overflow], execute_jo_taken

    # Skip the pointer, we're not jumping
    call inc_ip
    jz  0, execute_jo_done

execute_jo_taken:
    # Read the short pointer
    call read_cs_ip_b
    add [rb - 2], 0, [rb + ptr]
    call inc_ip

    # Add the 8-bit signed short pointer to the lo byte of 16-bit unsigned reg_ip
    add [rb + ptr], [reg_ip + 0], [reg_ip + 0]

    # Is the poiner negative?
    lt  0x7f, [rb + ptr], [rb + tmp]
    jnz [rb + tmp], execute_jo_negative

    # The pointer is positive, check for carry out of low byte of reg_ip
    lt [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jo_done

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte of reg_ip
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jo_done

    add [reg_ip + 1], -0x100, [reg_ip + 1]

    jz  0, execute_jo_done

execute_jo_negative:
    # The pointer is negative, adjust the result by -256
    add [reg_ip], -0x100, [reg_ip]

    # Check for borrow into low byte of reg_ip
    lt  [reg_ip + 0], 0, [rb + tmp]
    jz  [rb + tmp], execute_jo_done

    add [reg_ip + 0], 0x100, [reg_ip + 0]
    add [reg_ip + 1], -1, [reg_ip + 1]

    # Check for borrow into high byte of reg_ip
    lt  [reg_ip + 1], 0, [rb + tmp]
    jz  [rb + tmp], execute_jo_done

    add [reg_ip + 1], 0x100, [reg_ip + 1]

execute_jo_done:
    arb 2
    ret 0
.ENDFRAME

.EOF


##########
execute_jmp:
.FRAME addr;
    add [rb + addr], 0, [reg_ip]
    ret 1
.ENDFRAME

##########
execute_jsr:
.FRAME addr; ret_hi, ret_lo
    arb -2

    # JSR pushes ip - 1 to the stack, and rts adds + 1 to the address after it's popped
    # (JSR <addr-lo> ^<addr-hi> - the address pushed to stack is marked with a "^").

    # Decrement ip with wraparound
    add [reg_ip], -1, [rb - 1]
    add 0x10000, 0, [rb - 2]
    arb -2
    call modulo

    # Split the return addres into high and low part
    add [rb - 4], 0, [rb - 1]
    arb -1
    call split_16_8_8

    add [rb - 3], 0, [rb + ret_hi]
    add [rb - 4], 0, [rb + ret_lo]

    # Push both parts of the return address
    add [rb + ret_hi], 0, [rb - 1]
    arb -1
    call push

    add [rb + ret_lo], 0, [rb - 1]
    arb -1
    call push

    # Jump to address
    add [rb + addr], 0, [reg_ip]

    arb 2
    ret 1
.ENDFRAME


##########
execute_rts:
.FRAME
    # Pull return addres lo and hi and update reg_ip
    call pop
    add [rb - 2], 0, [reg_ip]

    call pop
    mul [rb - 2], 0x100, [rb - 2]
    add [reg_ip], [rb - 2], [reg_ip]

    # Increment reg_ip by 1 with wraparound
    add [reg_ip], 1, [rb - 1]
    add 0x10000, 0, [rb - 2]
    arb -2
    call modulo
    add [rb - 4], 0, [reg_ip]

    ret 0
.ENDFRAME



    db  not_implemented, 0, 0 # TODO    db  execute_jno, arg_short_ptr                      # 0x71 JNO SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jb, arg_short_ptr                       # 0x72 JB/JNAEI/JC SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jnb, arg_short_ptr                      # 0x73 JNB/JAEI/JNC SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jz, arg_short_ptr                       # 0x74 JE/JZ SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jnz, arg_short_ptr                      # 0x75 JNE/JNZ SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jna, arg_short_ptr                      # 0x76 JBE/JNA SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_ja, arg_short_ptr                       # 0x77 JNBE/JA SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_js, arg_short_ptr                       # 0x78 JS SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jns, arg_short_ptr                      # 0x79 JNS SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jp, arg_short_ptr                       # 0x7a JP/JPE SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jnp, arg_short_ptr                      # 0x7b JNP/JPO SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jl, arg_short_ptr                       # 0x7c JL/JNGE SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jnl, arg_short_ptr                      # 0x7d JNL/JGE SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jng, arg_short_ptr                      # 0x7e JLE/JNG SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jg, arg_short_ptr                       # 0x7f JNLE/JG SHORT-LABEL



        db  not_implemented, 0, 0 # TODO    db  execute_call, arg_far_ptr                       # 0x9a CALL FAR-PROC


    db  not_implemented, 0, 0 # TODO    db  execute_ret_near, arg_immediate_w               # 0xc2 RET IMMED16 (within segment)
    db  not_implemented, 0, 0 # TODO    db  execute_ret_near, arg_zero                      # 0xc3 RET (within segment)

    db  not_implemented, 0, 0 # TODO    db  execute_ret_far, arg_immediate_w                # 0xca RET IMMED16 (intersegment)
    db  not_implemented, 0, 0 # TODO    db  execute_ret_far, arg_zero                       # 0xcb RET (intersegment)


db  not_implemented, 0, 0 # TODO    db  execute_jcxz, arg_short_ptr                     # 0xe3 JCXZ SHORT-LABEL


    db  not_implemented, 0, 0 # TODO    db  execute_call, arg_near_ptr                      # 0xe8 CALL NEAR-PROC
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_near_ptr                       # 0xe9 JMP NEAR-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_far_ptr                        # 0xea JMP FAR-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_short_ptr                      # 0xeb JMP SHORT-LABEL

0xff:
    # 010 CALL REG16/MEM16 (within segment)
    # 011 CALL MEM16 (intersegment)
    # 100 JMP REG16/MEM16 (within segment)
    # 101 JMP MEM16 (intersegment)
