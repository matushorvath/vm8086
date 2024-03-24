.EXPORT execute_jo
.EXPORT execute_jno
.EXPORT execute_jc
.EXPORT execute_jnc
.EXPORT execute_jz
.EXPORT execute_jnz
.EXPORT execute_ja
.EXPORT execute_jna
.EXPORT execute_js
.EXPORT execute_jns
.EXPORT execute_jp
.EXPORT execute_jnp
.EXPORT execute_jl
.EXPORT execute_jnl
.EXPORT execute_jg
.EXPORT execute_jng

.EXPORT execute_jcxz

.EXPORT execute_jmp_short

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

.IMPORT reg_cx
.IMPORT reg_ip
.IMPORT inc_ip

##########
execute_jo:
.FRAME
    jnz [flag_overflow], execute_jo_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jo_done

execute_jo_taken:
    call execute_jmp_short

execute_jo_done:
    ret 0
.ENDFRAME

##########
execute_jno:
.FRAME
    jz  [flag_overflow], execute_jno_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jno_done

execute_jno_taken:
    call execute_jmp_short

execute_jno_done:
    ret 0
.ENDFRAME

##########
execute_jc:
.FRAME
    jnz [flag_carry], execute_jc_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jc_done

execute_jc_taken:
    call execute_jmp_short

execute_jc_done:
    ret 0
.ENDFRAME

##########
execute_jnc:
.FRAME
    jz  [flag_carry], execute_jnc_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jnc_done

execute_jnc_taken:
    call execute_jmp_short

execute_jnc_done:
    ret 0
.ENDFRAME

##########
execute_jz:
.FRAME
    jnz [flag_zero], execute_jz_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jz_done

execute_jz_taken:
    call execute_jmp_short

execute_jz_done:
    ret 0
.ENDFRAME

##########
execute_jnz:
.FRAME
    jz  [flag_zero], execute_jnz_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jnz_done

execute_jnz_taken:
    call execute_jmp_short

execute_jnz_done:
    ret 0
.ENDFRAME

##########
execute_ja:
.FRAME
    # CF or ZF == 0
    jnz [flag_carry], execute_ja_not_taken
    jnz [flag_zero], execute_ja_not_taken

    call execute_jmp_short
    jz  0, execute_ja_done

execute_ja_not_taken:
    # Skip the pointer and don't jump
    call inc_ip

execute_ja_done:
    ret 0
.ENDFRAME

##########
execute_jna:
.FRAME
    # CF or ZF == 1
    jnz [flag_carry], execute_jna_taken
    jnz [flag_zero], execute_jna_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jna_done

execute_jna_taken:
    call execute_jmp_short

execute_jna_done:
    ret 0
.ENDFRAME

##########
execute_js:
.FRAME
    jnz [flag_sign], execute_js_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_js_done

execute_js_taken:
    call execute_jmp_short

execute_js_done:
    ret 0
.ENDFRAME

##########
execute_jns:
.FRAME
    jz  [flag_sign], execute_jns_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jns_done

execute_jns_taken:
    call execute_jmp_short

execute_jns_done:
    ret 0
.ENDFRAME

##########
execute_jp:
.FRAME
    jnz [flag_parity], execute_jp_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jp_done

execute_jp_taken:
    call execute_jmp_short

execute_jp_done:
    ret 0
.ENDFRAME

##########
execute_jnp:
.FRAME
    jz  [flag_parity], execute_jnp_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jnp_done

execute_jnp_taken:
    call execute_jmp_short

execute_jnp_done:
    ret 0
.ENDFRAME

##########
execute_jl:
.FRAME tmp
    arb -1

    # SF xor OF == 1
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jz  [rb + tmp], execute_jl_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jl_done

execute_jl_taken:
    call execute_jmp_short

execute_jl_done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jnl:
.FRAME tmp
    arb -1

    # SF xor OF == 0
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jnz [rb + tmp], execute_jnl_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jnl_done

execute_jnl_taken:
    call execute_jmp_short

execute_jnl_done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jg:
.FRAME tmp
    arb -1

    # (SF xor OF) or ZF == 0
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jz  [rb + tmp], execute_jg_not_taken
    jnz [flag_zero], execute_jg_not_taken

    call execute_jmp_short
    jz  0, execute_jg_done

execute_jg_not_taken:
    # Skip the pointer and don't jump
    call inc_ip

execute_jg_done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jng:
.FRAME tmp
    arb -1

    # (SF xor OF) or ZF == 1
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jz  [rb + tmp], execute_jng_taken
    jnz [flag_zero], execute_jng_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jng_done

execute_jng_taken:
    call execute_jmp_short

execute_jng_done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jcxz:
.FRAME
    jz  [reg_cx], execute_jcxz_taken

    # Skip the pointer and don't jump
    call inc_ip
    jz  0, execute_jcxz_done

execute_jcxz_taken:
    call execute_jmp_short

execute_jcxz_done:
    ret 0
.ENDFRAME

##########
execute_jmp_short:
.FRAME ptr, tmp
    arb -2

    # Read the short pointer
    call read_cs_ip_b
    add [rb - 2], 0, [rb + ptr]
    call inc_ip

    # Add the 8-bit signed short pointer to the lo byte of 16-bit unsigned reg_ip
    add [rb + ptr], [reg_ip + 0], [reg_ip + 0]

    # Is the pointer negative?
    lt  0x7f, [rb + ptr], [rb + tmp]
    jnz [rb + tmp], execute_jmp_short_negative

    # The pointer is positive, check for carry out of low byte of reg_ip
    lt [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jmp_short_done

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte of reg_ip
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_jmp_short_done

    add [reg_ip + 1], -0x100, [reg_ip + 1]

    jz  0, execute_jmp_short_done

execute_jmp_short_negative:
    # The pointer is negative, adjust the result by -256
    add [reg_ip], -0x100, [reg_ip]

    # Check for borrow into low byte of reg_ip
    lt  [reg_ip + 0], 0, [rb + tmp]
    jz  [rb + tmp], execute_jmp_short_done

    add [reg_ip + 0], 0x100, [reg_ip + 0]
    add [reg_ip + 1], -1, [reg_ip + 1]

    # Check for borrow into high byte of reg_ip
    lt  [reg_ip + 1], 0, [rb + tmp]
    jz  [rb + tmp], execute_jmp_short_done

    add [reg_ip + 1], 0x100, [reg_ip + 1]

execute_jmp_short_done:
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


    db  not_implemented, 0, 0 # TODO    db  execute_call, arg_near_ptr                      # 0xe8 CALL NEAR-PROC
    db  not_implemented, 0, 0 # TODO    db  execute_call, arg_far_ptr                       # 0x9a CALL FAR-PROC
    0xff: # 010 CALL REG16/MEM16 (within segment)
    0xff: # 011 CALL MEM16 (intersegment)

    db  not_implemented, 0, 0 # TODO    db  execute_ret_near, arg_immediate_w               # 0xc2 RET IMMED16 (within segment)
    db  not_implemented, 0, 0 # TODO    db  execute_ret_near, arg_zero                      # 0xc3 RET (within segment)

    db  not_implemented, 0, 0 # TODO    db  execute_ret_far, arg_immediate_w                # 0xca RET IMMED16 (intersegment)
    db  not_implemented, 0, 0 # TODO    db  execute_ret_far, arg_zero                       # 0xcb RET (intersegment)

    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_near_ptr                       # 0xe9 JMP NEAR-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_far_ptr                        # 0xea JMP FAR-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_jmp, arg_short_ptr                      # 0xeb JMP SHORT-LABEL
    0xff: # 100 JMP REG16/MEM16 (within segment)
    0xff: # 101 JMP MEM16 (intersegment)

    db  not_implemented, 0, 0 # TODO    db  execute_loopne, arg_short_ptr                   # 0xe0 LOOPNE/LOOPNZ SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_loope, arg_short_ptr                    # 0xe1 LOOPE/LOOPZ SHORT-LABEL
    db  not_implemented, 0, 0 # TODO    db  execute_loop, arg_short_ptr                     # 0xe2 LOOP SHORT-LABEL
