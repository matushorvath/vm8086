; SUB/SBB 8-bit, with and without input carry, all possible numbers

%macro test_8_all 2-3 ""
    mov bl, 0       ; first number
    mov cl, 0       ; second number

%%loop_bl:
    mov dh, bl      ; the correct result
    xor si, si      ; the correct flags

%ifidni %3,carry
    inc dh          ; compensate for carry
%endif

%%loop_cl:
    %2              ; clear or set carry
    mov dl, bl
    %1 dl, cl       ; dl = bl OP cl
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

    inc dh          ; calculate next correct result

    inc cl
    jnz %%loop_cl

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
    test_8_all adc, clc
    mark 0x61
    test_8_all adc, stc, carry
    mark 0x62
    test_8_all add, clc
    mark 0x63
    test_8_all add, stc
