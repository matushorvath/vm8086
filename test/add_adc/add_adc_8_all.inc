; SUB/SBB 8-bit, with and without input carry, all possible numbers

%macro test_8_all 2-3 ""
    mov bl, 0       ; first number
    mov cl, 0       ; second number

%%loop_bl:
    mov dh, bl      ; the correct result

%ifidni %3,carry
    inc dh          ; compensate for carry
%endif

%%loop_cl:
    %2              ; clear or set carry
    mov dl, bl
    %1 dl, cl       ; dl = bl OP cl

    cmp dl, dh      ; compare calculated and correct result
    jne %%fail

    ; TODO compare flags

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
