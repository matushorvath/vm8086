; TODO negative short pointer
; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test conditional jumps

%macro test_conditional 2 ; instruction, flags
    ; set flags
    mov dx, %2
    push dx
    popf

    ; try jumping
    mov ax, 1
    %1  %%target
    mov ax, 0

%%target:
    out 0x42, al
%endmacro

    ; ----ODIT SZ-A-P-C

    test_conditional jo,  0b_00000000_00000000
    test_conditional jo,  0b_00001000_00000000

    test_conditional jno, 0b_00000000_00000000
    test_conditional jno, 0b_00001000_00000000

    test_conditional jc,  0b_00000000_00000000
    test_conditional jc,  0b_00000000_00000001

    test_conditional jnc, 0b_00000000_00000000
    test_conditional jnc, 0b_00000000_00000001

    test_conditional jz,  0b_00000000_00000000
    test_conditional jz,  0b_00000000_01000000

    test_conditional jnz, 0b_00000000_00000000
    test_conditional jnz, 0b_00000000_01000000

    test_conditional ja,  0b_00000000_00000000
    test_conditional ja,  0b_00000000_00000001
    test_conditional ja,  0b_00000000_01000000
    test_conditional ja,  0b_00000000_01000001

    test_conditional jna, 0b_00000000_00000000
    test_conditional jna, 0b_00000000_00000001
    test_conditional jna, 0b_00000000_01000000
    test_conditional jna, 0b_00000000_01000001

    test_conditional js,  0b_00000000_00000000
    test_conditional js,  0b_00000000_10000000

    test_conditional jns, 0b_00000000_00000000
    test_conditional jns, 0b_00000000_10000000

    test_conditional jp,  0b_00000000_00000000
    test_conditional jp,  0b_00000000_00000100

    test_conditional jnp, 0b_00000000_00000000
    test_conditional jnp, 0b_00000000_00000100

    test_conditional jl,  0b_00000000_00000000
    test_conditional jl,  0b_00000000_10000000
    test_conditional jl,  0b_00001000_00000000
    test_conditional jl,  0b_00001000_10000000

    test_conditional jnl, 0b_00000000_00000000
    test_conditional jnl, 0b_00000000_10000000
    test_conditional jnl, 0b_00001000_00000000
    test_conditional jnl, 0b_00001000_10000000

    test_conditional jg,  0b_00000000_00000000
    test_conditional jg,  0b_00000000_01000000
    test_conditional jg,  0b_00000000_10000000
    test_conditional jg,  0b_00000000_11000000
    test_conditional jg,  0b_00001000_00000000
    test_conditional jg,  0b_00001000_01000000
    test_conditional jg,  0b_00001000_10000000
    test_conditional jg,  0b_00001000_11000000

    test_conditional jng, 0b_00000000_00000000
    test_conditional jng, 0b_00000000_01000000
    test_conditional jng, 0b_00000000_10000000
    test_conditional jng, 0b_00000000_11000000
    test_conditional jng, 0b_00001000_00000000
    test_conditional jng, 0b_00001000_01000000
    test_conditional jng, 0b_00001000_10000000
    test_conditional jng, 0b_00001000_11000000
