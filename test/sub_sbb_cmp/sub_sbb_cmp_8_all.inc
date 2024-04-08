; SUB/SBB 8-bit, with and without input carry, all possible numbers

%macro test_8_all 2-3 ""
    mov bl, 0       ; first number
    mov cl, 0       ; second number

%%loop_bl:
    mov dh, bl      ; the correct result
    xor si, si      ; the correct flags

%ifidni %3,carry
    dec dh          ; compensate for carry
%endif

%%loop_cl:
    %2              ; clear or set carry
    mov dl, bl
    %1 dl, cl       ; dl = bl OP cl
    pushf

%ifnidni %3,no_result
    cmp dl, dh      ; compare calculated and correct result
    jne %%fail
%endif

    ; relevant flags: ----O--- SZ-A-P-C
    xor si, si

    cmp dh, 0x00
    jne %%nz
    or  si, 0b_00000000_01000000
%%nz

    mov ch, dh
    and ch, 0b_10000000
    jz  %%ns
    or  si, 0b_00000000_10000000
%%ns

    pop ax          ; compare real flags with correct ones
    and ax, 0b_00000000_11000000         ; TODO 0b_00001000_11010101
    cmp ax, si
    jne %%fail

    dec dh          ; calculate next correct result

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

    ; the test itself uses cmp, so we better make sure cmp works first
    ; TODO add a separate test to check that CMP with ZF works correctly, that's the only thing we use
    mark 0x60
    test_8_all cmp, clc, no_result
    mark 0x61
    test_8_all cmp, stc, no_result

    mark 0x62
    test_8_all sbb, clc
    mark 0x63
    test_8_all sbb, stc, carry
    mark 0x64
    test_8_all sub, clc
    mark 0x65
    test_8_all sub, stc
