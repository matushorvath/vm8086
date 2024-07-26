.EXPORT execute_loop
.EXPORT execute_loopz
.EXPORT execute_loopnz
.EXPORT execute_jcxz
.EXPORT dec_cx

# From jump.s
.IMPORT execute_jmp_short

# From state.s
.IMPORT flag_zero
.IMPORT reg_cx
.IMPORT inc_ip_b

##########
execute_loop:
.FRAME
    call dec_cx

    jnz [reg_cx + 0], .taken
    jnz [reg_cx + 1], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_loopz:
.FRAME
    call dec_cx

    jnz [reg_cx + 0], .taken
    jnz [reg_cx + 1], .taken

.not_taken:
    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    jz  [flag_zero], .not_taken

    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_loopnz:
.FRAME
    call dec_cx

    jnz [reg_cx + 0], .taken
    jnz [reg_cx + 1], .taken

.not_taken:
    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    jnz [flag_zero], .not_taken

    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jcxz:
.FRAME
    jnz [reg_cx + 0], .taken
    jnz [reg_cx + 1], .taken

    call execute_jmp_short
    ret 0

.taken:
    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0
.ENDFRAME

##########
dec_cx:
.FRAME tmp
    arb -1

    # Decrement the value
    add [reg_cx + 0], -1, [reg_cx + 0]

    # Check for borrow into low byte
    lt  [reg_cx + 0], 0, [rb + tmp]
    jz  [rb + tmp], .done

    add [reg_cx + 0], 0x100, [reg_cx + 0]
    add [reg_cx + 1], -1, [reg_cx + 1]

    # Check for borrow into high byte
    lt  [reg_cx + 1], 0, [rb + tmp]
    jz  [rb + tmp], .done

    add [reg_cx + 1], 0x100, [reg_cx + 1]

.done:
    arb 1
    ret 0
.ENDFRAME

.EOF
