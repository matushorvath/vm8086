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

# From util/error.s
.IMPORT report_error

# From jump.s
.IMPORT execute_jmp_short

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow
.IMPORT inc_ip_b

##########
execute_jo:
.FRAME
    jnz [flag_overflow], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jno:
.FRAME
    jz  [flag_overflow], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jc:
.FRAME
    jnz [flag_carry], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jnc:
.FRAME
    jz  [flag_carry], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jz:
.FRAME
    jnz [flag_zero], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jnz:
.FRAME
    jz  [flag_zero], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_ja:
.FRAME
    # CF or ZF == 0
    jnz [flag_carry], .not_taken
    jnz [flag_zero], .not_taken

    call execute_jmp_short
    ret 0

.not_taken:
    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0
.ENDFRAME

##########
execute_jna:
.FRAME
    # CF or ZF == 1
    jnz [flag_carry], .taken
    jnz [flag_zero], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_js:
.FRAME
    jnz [flag_sign], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jns:
.FRAME
    jz  [flag_sign], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jp:
.FRAME
    jnz [flag_parity], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jnp:
.FRAME
    jz  [flag_parity], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

.taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jl:
.FRAME tmp
    arb -1

    # SF xor OF == 1
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jz  [rb + tmp], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    jz  0, .done

.taken:
    call execute_jmp_short

.done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jnl:
.FRAME tmp
    arb -1

    # SF xor OF == 0
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jnz [rb + tmp], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    jz  0, .done

.taken:
    call execute_jmp_short

.done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jg:
.FRAME tmp
    arb -1

    # (SF xor OF) or ZF == 0
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jz  [rb + tmp], .not_taken
    jnz [flag_zero], .not_taken

    call execute_jmp_short
    jz  0, .done

.not_taken:
    # Skip the pointer and don't jump
    call inc_ip_b

.done:
    arb 1
    ret 0
.ENDFRAME

##########
execute_jng:
.FRAME tmp
    arb -1

    # (SF xor OF) or ZF == 1
    eq  [flag_sign], [flag_overflow], [rb + tmp]
    jz  [rb + tmp], .taken
    jnz [flag_zero], .taken

    # Skip the pointer and don't jump
    call inc_ip_b
    jz  0, .done

.taken:
    call execute_jmp_short

.done:
    arb 1
    ret 0
.ENDFRAME

.EOF
