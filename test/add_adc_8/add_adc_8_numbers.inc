; ADD/ADC 8-bit, with and without input carry
    mov ax, 0
    mov bx, 0
    mov dx, 0
    mov si, 0
    mov di, 0

; test given instruction and carry flag state against given test set
%macro test_add_8 3                     ; add_instruction, carry_flag_instruction, test_set
    mov cx, word [cs:%3]
    mov bp, 2

%%loop:
    %2                                  ; clear or set carry
    mov al, byte [cs:%3 + bp + 0]
    mov dl, al
    mov bl, byte [cs:%3 + bp + 1]
    %1  dl, bl                          ; dl = al OP bl
    pushf

    mov dh, byte [cs:%3 + bp + 2]
    cmp dl, dh                          ; compare calculated and correct result
    jne %%done

    ; relevant flags: ----O--- SZ-A-P-C
    pop di                              ; compare real flags with correct ones
    and di, 0b_00000000_11000100        ; TODO do not mask flags
    mov si, word [cs:%3 + bp + 3]
    cmp di, si
    jne %%done

    add bp, add_8_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro


; run the tests
mark 0x60
test_add_8 adc, clc, add_8_interesting_set_0
mark 0x61
test_add_8 adc, clc, add_8_generic_set_0

mark 0x62
test_add_8 adc, stc, add_8_interesting_set_1
mark 0x63
test_add_8 adc, stc, add_8_generic_set_1

mark 0x64
test_add_8 add, clc, add_8_interesting_set_0
mark 0x65
test_add_8 add, clc, add_8_generic_set_0

mark 0x66
test_add_8 add, stc, add_8_interesting_set_0
mark 0x67
test_add_8 add, stc, add_8_generic_set_0


; generate test data for adding two numbers
%macro add_8_data 3                     ; op1, op2, carry
    %assign res (%1 + %2 + %3) % 0x100

    ; relevant flags: ----O--- SZ-A-P-C
    %assign sfl res >= 0x80 ? 0b_00000000_10000000 : 0
    %assign zfl res == 0 ? 0b_00000000_01000000 : 0
    %assign pfl (\
            (res & 0x80 != 0) + (res & 0x40 != 0) + (res & 0x20 != 0) + (res & 0x10 != 0) + \
            (res & 0x08 != 0) + (res & 0x04 != 0) + (res & 0x02 != 0) + (res & 0x01 != 0) \
        ) % 2 == 0 ? 0b_00000000_00000100 : 0
    %assign flags sfl | zfl | pfl

    ;%warning %1, %2, res, flags
    dw  %1, %2, res
    dw  flags
%endmacro

add_8_data_size equ 1 + 1 + 1 + 2       ; op1, op2, res, flags

; test interesting numbers
%macro add_8_interesting_set 1          ; carry
    %assign cnt_a 8
    %assign cnt_b 8
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %rep cnt_b
            %assign a %sel(ai, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            %assign b %sel(bi, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            add_8_data a, b, %1
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; complete test data with/without carry
%macro add_8_generic_set 1              ; carry
    %assign step_a 13
    %assign step_b 11
    %assign cnt_a 0x100 / step_a
    %assign cnt_b 0x100 / step_b

    dw  cnt_a * cnt_b

    %assign a 0
    %rep cnt_a
        %assign b 0
        %rep cnt_b
            add_8_data a, b, %1
        %assign b b + step_b
        %endrep
    %assign a a + step_a
    %endrep
%endmacro


[section .data start=data_addr]

add_8_interesting_set_0:
    add_8_interesting_set 0
add_8_interesting_set_1:
    add_8_interesting_set 1

add_8_generic_set_0:
    add_8_generic_set 0
add_8_generic_set_1:
    add_8_generic_set 1

__?SECT?__
