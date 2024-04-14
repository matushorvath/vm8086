; ADD/ADC 16-bit, with and without input carry, all possible numbers

SKIP    equ 128     ; skip every SKIP numbers to speed up the test

%macro test_16_all 2-3 ""
    mov bx, 0       ; first number
    mov cx, 0       ; second number

%%loop_bx:
    mov dx, bx      ; the correct result
    xor si, si      ; the correct flags

%ifidni %3,carry
    inc dx          ; compensate for carry
%endif

%%loop_cx:
    %2              ; clear or set carry
    mov di, bx
    %1 di, cx       ; di = bx OP cx
    pushf

%ifnidni %3,no_result
    cmp di, dx      ; compare calculated and correct result
    jne %%fail
%endif

    ; relevant flags: ----O--- SZ-A-P-C
    xor si, si

    test dx, dx
    jnz %%nz
    or  si, 0b_00000000_01000000
%%nz:

    mov ax, dx
    and ax, 0b_10000000_00000000
    jz  %%ns
    or  si, 0b_00000000_10000000
%%ns:

    mov al, dl
    mov ah, 0
    mov bp, ax
    mov al, [cs:parity + bp]
    test al, al
    jz  %%np
    or  si, 0b_00000000_00000100
%%np:

    pop ax          ; compare real flags with correct ones
    and ax, 0b_00000000_11000100         ; TODO 0b_00001000_11010101
    cmp ax, si
    jne %%fail

    ; TODO use inc, dec instead of add, sub below; for now they are too slow
    add dx, SKIP    ; calculate next correct result

    add cx, SKIP
    jnz %%loop_cx

%ifdef BOCHS
    mov al, ' '
    out 0xe9, al
%endif

    add bx, SKIP
    jnz %%loop_bx

    jmp %%done

%%fail:
    dump_state      ; dump state when the test failed

%%done:
%endmacro

    mark 0x70
    test_16_all adc, clc
    mark 0x71
    test_16_all adc, stc, carry
    mark 0x72
    test_16_all add, clc
    mark 0x73
    test_16_all add, stc
