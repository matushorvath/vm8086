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
    jnz [flag_overflow], execute_jo_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jo_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jno:
.FRAME
    jz  [flag_overflow], execute_jno_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jno_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jc:
.FRAME
    jnz [flag_carry], execute_jc_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jc_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jnc:
.FRAME
    jz  [flag_carry], execute_jnc_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jnc_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jz:
.FRAME
    jnz [flag_zero], execute_jz_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jz_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jnz:
.FRAME
    jz  [flag_zero], execute_jnz_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jnz_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_ja:
.FRAME
    # CF or ZF == 0
    jnz [flag_carry], execute_ja_not_taken
    jnz [flag_zero], execute_ja_not_taken

    call execute_jmp_short
    ret 0

execute_ja_not_taken:
    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0
.ENDFRAME

##########
execute_jna:
.FRAME
    # CF or ZF == 1
    jnz [flag_carry], execute_jna_taken
    jnz [flag_zero], execute_jna_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jna_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_js:
.FRAME
    jnz [flag_sign], execute_js_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_js_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jns:
.FRAME
    jz  [flag_sign], execute_jns_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jns_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jp:
.FRAME
    jnz [flag_parity], execute_jp_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jp_taken:
    call execute_jmp_short
    ret 0
.ENDFRAME

##########
execute_jnp:
.FRAME
    jz  [flag_parity], execute_jnp_taken

    # Skip the pointer and don't jump
    call inc_ip_b
    ret 0

execute_jnp_taken:
    call execute_jmp_short
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
    call inc_ip_b
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
    call inc_ip_b
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
    call inc_ip_b

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
    call inc_ip_b
    jz  0, execute_jng_done

execute_jng_taken:
    call execute_jmp_short

execute_jng_done:
    arb 1
    ret 0
.ENDFRAME

.EOF
