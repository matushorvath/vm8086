; NEG 8-bit, all possible numbers

%macro test_8_all 0
    mov bl, 0       ; number to negate
    mov dh, 0       ; the correct result

%%loop_bl:
    xor si, si      ; the correct flags

    mov dl, bl
    neg dl          ; dl = neg bl
    pushf

    cmp dl, dh      ; compare calculated and correct result
    jne %%fail

    ; relevant flags: ----O--- SZ-A-P-C
    xor si, si

    test dh, dh
    jnz %%nz
    or  si, 0b_00000000_01000000
%%nz:

    mov ah, dh
    and ah, 0b_10000000
    jz  %%ns
    or  si, 0b_00000000_10000000
%%ns:

    mov al, dh
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

    dec dh          ; calculate next correct result

%ifdef BOCHS
    mov al, ' '
    out 0xe9, al
%endif

    inc bl
    jnz %%loop_bl

    jmp %%done

%%fail:
    dump_state      ; dump state when the test failed

%%done:
%endmacro

    mark 0x60
    test_8_all
