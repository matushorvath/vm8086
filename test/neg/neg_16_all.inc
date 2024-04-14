; NEG 16-bit, all possible numbers

SKIP    equ 128     ; skip every SKIP numbers to speed up the test

%macro test_16_all 0
    mov bx, 0       ; number to negate
    mov dx, bx      ; the correct result

%%loop_bx:
    xor si, si      ; the correct flags

    mov di, bx
    neg di          ; di = neg bx
    pushf

    cmp di, dx      ; compare calculated and correct result
    jne %%fail

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
    sub dx, SKIP    ; calculate next correct result

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
    test_16_all
