; SUB/SBB 16-bit, with and without input carry, all possible numbers

SKIP    equ 128     ; skip every SKIP numbers to speed up the test

%macro test_16_all 2-3 ""
    mov bx, 0       ; first number
    mov cx, 0       ; second number

%%loop_bx:
    mov di, bx      ; the correct result

%ifidni %3,carry
    inc di          ; compensate for carry
%endif

%%loop_cx:
    %2              ; clear or set carry
    mov dx, bx
    %1 dx, cx       ; dx = bx OP cx

%ifnidni %3,no_result
    cmp dx, di      ; compare calculated and correct result
    jne %%fail
%endif

    ; TODO compare flags
    ; TODO use inc, dec instead of add, sub below; for now they are too slow

    add di, SKIP    ; calculate next correct result

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
