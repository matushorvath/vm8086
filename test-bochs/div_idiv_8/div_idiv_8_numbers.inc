; DIV/IDIV 8-bit
    mov ax, 0
    mov bx, 0
    mov dx, 0
    mov si, 0
    mov di, 0

; test given instruction and carry flag state against given test set
%macro test_div_8 2                     ; div_instruction, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov dx, word [cs:%2 + bp + 0]
    mov ax, dx
    mov bl, byte [cs:%2 + bp + 2]
    mov bh, byte [cs:%2 + bp + 3]

    clc
    %1  bl                              ; al,ah = dx OP bl
    jc  %%divide_error

    ; was division supposed to pass without an interrupt?
    test bh, bh
    jnz %%done

    mov di, word [cs:%2 + bp + 4]
    cmp di, ax                          ; compare calculated and correct result
    jne %%done

    jmp %%next

%%divide_error:
    ; was the division supposed to fail?
    test bh, bh
    jnz %%next
    cmp cx, 0x00                        ; set ZF = 0

%%next:
    add bp, div_8_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro


; run the tests
mark 0x60
test_div_8 div, div_8_interesting_set
mark 0x61
test_div_8 div, div_8_generic_set

mark 0x62
test_div_8 idiv, idiv_8_interesting_set
mark 0x63
test_div_8 idiv, idiv_8_generic_set


; generate test data for dividing two unsigned numbers
%macro div_8_data 2                     ; op1, op2
    %assign res 0x00
    %assign mod 0x00

    %if %2 == 0
        %assign de 1
    %else
        %if (%1 / %2) > 0xff
            %assign de 1
        %else
            %assign res (%1 / %2) & 0xff
            %assign mod (%1 % %2)
            %assign de 0
        %endif
    %endif

    ;%warning %1, %2, de, res, mod
    dw  %1
    db  %2, de, res, mod
%endmacro

; generate test data for dividing two signed numbers
%macro idiv_8_data 2                    ; op1, op2
    %assign op1 (%1 < 0x8000 ? %1 : %1 - 0x10000)
    %assign op2 (%2 < 0x80 ? %2 : %2 - 0x100)

    %assign res 0x00
    %assign mod 0x00

    %if op2 == 0
        %assign de 1
    %else
        %if (op1 // op2) < -0x80 || (op1 // op2) > 0x7f
            %assign de 1
        %else
            %assign res (op1 // op2) >= 0 ? (op1 // op2) : (op1 // op2) + 0x100
            %assign mod (op1 %% op2)
            %assign de 0
        %endif
    %endif

    ; %warning %1, %2, de, res, mod
    dw  %1
    db  %2, de, res, mod
%endmacro

div_8_data_size equ 2 + 1 + 1 + 1 + 1   ; op1, op2, de, res, mod

; test interesting numbers
%macro make_div_8_interesting_set 1
    %assign cnt_a 20
    %assign cnt_b 8
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %rep cnt_b
            %assign a %sel(ai, \
                0x0000, 0x0001, 0x007e, 0x007f, 0x0080, 0x0081, 0x00fe, 0x00ff, 0x0100, 0x0101, \
                0x017e, 0x017f, 0x0180, 0x0181, 0x7ffe, 0x7fff, 0x8000, 0x8001, 0xfffe, 0xffff)
            %assign b %sel(bi, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            %1_8_data a, b
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; complete test data with/without carry
%macro make_div_8_generic_set 1
    %assign step_a 3271
    %assign step_b 11
    %assign cnt_a 0x10000 / step_a
    %assign cnt_b 0x100 / step_b

    dw  cnt_a * cnt_b

    %assign a 0
    %rep cnt_a
        %assign b 0
        %rep cnt_b
            %1_8_data a, b
            %assign b b + step_b
        %endrep
        %assign a a + step_a
    %endrep
%endmacro


[section .data start=data_addr]

div_8_interesting_set:
    make_div_8_interesting_set div
div_8_generic_set:
    make_div_8_generic_set div
idiv_8_interesting_set:
    make_div_8_interesting_set idiv
idiv_8_generic_set:
    make_div_8_generic_set idiv

__?SECT?__
