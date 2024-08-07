; TODO negative short pointer
; TODO carry from low byte (reg_ip low byte + short pointer is more than 0x100)
; TODO borrow to low byte (reg_ip low byte + short pointer is less than 0)
; TODO overflow (reg_ip + short pointer is more than 0x1000)
; TODO underflow (reg_ip + short pointer is less than 0)

    ; test LOOP, LOOPZ, LOOPNZ and JCXZ

%macro test_loop 2-3 0b_00000000_00000000 ; instruction, cx value, flags
    ; set flags and cx
    mov dx, %3
    push dx
    popf

    mov cx, %2

    ; try jumping
    mov ax, 1
    %1  %%target
    mov ax, 0

%%target:
    dump_state
%endmacro

    test_loop loop, 0
    test_loop loop, 1
    test_loop loop, 0x101

    test_loop loopz, 0,     0b_00000000_00000000
    test_loop loopz, 0,     0b_00000000_01000000
    test_loop loopz, 1,     0b_00000000_00000000
    test_loop loopz, 1,     0b_00000000_01000000
    test_loop loopz, 0x101, 0b_00000000_00000000
    test_loop loopz, 0x101, 0b_00000000_01000000

    test_loop loopnz, 0,     0b_00000000_00000000
    test_loop loopnz, 0,     0b_00000000_01000000
    test_loop loopnz, 1,     0b_00000000_00000000
    test_loop loopnz, 1,     0b_00000000_01000000
    test_loop loopnz, 0x101, 0b_00000000_00000000
    test_loop loopnz, 0x101, 0b_00000000_01000000

    test_loop jcxz, 0
    test_loop jcxz, 1
    test_loop jcxz, 0x101
