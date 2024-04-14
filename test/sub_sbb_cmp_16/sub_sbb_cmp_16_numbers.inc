; SUB/SBB/CMP 16-bit, with and without input carry
    mov ax, 0
    mov bx, 0
    mov dx, 0
    mov si, 0
    mov di, 0

; test given instruction and carry flag state against given test set
%macro test_sub_16 3                    ; sub_instruction, carry_flag_instruction, test_set
    mov cx, word [cs:%3]
    mov bp, 2

%%loop:
    %2                                  ; clear or set carry
    mov ax, word [cs:%3 + bp + 0]
    mov dx, ax
    mov bx, word [cs:%3 + bp + 2]
    %1  dx, bx                          ; dx = ax OP bx
    pushf

    mov di, word [cs:%3 + bp + 4]
%ifnidni %4,ignore_result
    cmp dx, di                          ; compare calculated and correct result
    jne %%done
%endif

    ; relevant flags: ----O--- SZ-A-P-C
    pop di                              ; compare real flags with correct ones
    and di, 0b_00000000_11000100        ; TODO do not mask flags
    mov si, word [cs:%3 + bp + 6]
    cmp di, si
    jne %%done

    add bp, sub_16_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro


; run the tests
mark 0x60
test_sub_16 adc, clc, sub_16_interesting_set_0
mark 0x61
test_sub_16 adc, clc, sub_16_generic_set_0

mark 0x62
test_sub_16 adc, stc, sub_16_interesting_set_1
mark 0x63
test_sub_16 adc, stc, sub_16_generic_set_1

mark 0x64
test_sub_16 sub, clc, sub_16_interesting_set_0
mark 0x65
test_sub_16 sub, clc, sub_16_generic_set_0

mark 0x66
test_sub_16 sub, stc, sub_16_interesting_set_0
mark 0x67
test_sub_16 sub, stc, sub_16_generic_set_0


; generate test data for subtracting two numbers
%macro sub_16_data 3                    ; op1, op2, carry
    %assign res (%1 - %2 - %3) % 0x10000

    ; relevant flags: ----O--- SZ-A-P-C
    %assign sfl res >= 0x8000 ? 0b_00000000_10000000 : 0
    %assign zfl res == 0 ? 0b_00000000_01000000 : 0
    %assign pfl (\
            (res & 0x80 != 0) + (res & 0x40 != 0) + (res & 0x20 != 0) + (res & 0x10 != 0) + \
            (res & 0x08 != 0) + (res & 0x04 != 0) + (res & 0x02 != 0) + (res & 0x01 != 0) \
        ) % 2 == 0 ? 0b_00000000_00000100 : 0
    %assign flags sfl | zfl | pfl

    ;%warning %1, %2, res, flags
    dw  %1, %2, res, flags
%endmacro

sub_16_data_size equ 2 + 2 + 2 + 2      ; op1, op2, res, flags

; test interesting numbers
%macro sub_16_interesting_set 1         ; carry
    %assign cnt_a 20
    %assign cnt_b 20
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %rep cnt_b
            %assign a %sel(ai, \
                0x0000, 0x0001, 0x007e, 0x007f, 0x0080, 0x0081, 0x00fe, 0x00ff, 0x0100, 0x0101, \
                0x017e, 0x017f, 0x0180, 0x0181, 0x7ffe, 0x7fff, 0x8000, 0x8001, 0xfffe, 0xffff)
            %assign b %sel(bi, \
                0x0000, 0x0001, 0x007e, 0x007f, 0x0080, 0x0081, 0x00fe, 0x00ff, 0x0100, 0x0101, \
                0x017e, 0x017f, 0x0180, 0x0181, 0x7ffe, 0x7fff, 0x8000, 0x8001, 0xfffe, 0xffff)
            sub_16_data a, b, %1
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; complete test data with/without carry
%macro sub_16_generic_set 1             ; carry
    %assign step_a 3271
    %assign step_b 3259
    %assign cnt_a 0x10000 / step_a
    %assign cnt_b 0x10000 / step_b

    dw  cnt_a * cnt_b

    %assign a 0
    %rep cnt_a
        %assign b 0
        %rep cnt_b
            sub_16_data a, b, %1
            %assign b b + step_b
        %endrep
        %assign a a + step_a
    %endrep
%endmacro


[section .data start=data_addr]

sub_16_interesting_set_0:
    sub_16_interesting_set 0
sub_16_interesting_set_1:
    sub_16_interesting_set 1

sub_16_generic_set_0:
    sub_16_generic_set 0
sub_16_generic_set_1:
    sub_16_generic_set 1

__?SECT?__
