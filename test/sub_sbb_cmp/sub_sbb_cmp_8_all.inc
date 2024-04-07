; SUB/SBB 8-bit, with and without input carry, all possible numbers
; TODO

%macro test_8_all 2
    mov bl, 0
    mov cl, 0
    mov dh, 0

%%loop_bl:

%%loop_cl:
    %2
    mov dl, bl
    %1 dl, cl

    dump_dx
    pushf
    pop dx
    dump_dx

    inc cl
    jnz %%loop_cl

    inc bl
    jnz %%loop_bl
%endmacro

    mark 0x60
    test_8_all sbb, clc
    mark 0x61
    test_8_all sbb, stc
    mark 0x62
    test_8_all sub, clc
    mark 0x63
    test_8_all sub, stc
    mark 0x64
    test_8_all cmp, clc
    mark 0x65
    test_8_all cmp, stc
