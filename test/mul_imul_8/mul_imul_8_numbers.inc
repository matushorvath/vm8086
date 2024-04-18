; MUL/IMUL 8-bit
    mov ax, 0
    mov bx, 0
    mov dx, 0
    mov si, 0
    mov di, 0

; test given instruction and carry flag state against given test set
%macro test_mul_8 2                     ; mul_instruction, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov dl, byte [cs:%2 + bp + 0]
    mov al, dl
    mov bl, byte [cs:%2 + bp + 1]
    %1  bl                              ; ax = dl OP bl
    pushf

    mov di, word [cs:%2 + bp + 2]
    cmp di, ax                          ; compare calculated and correct result
    jne %%done

    ; relevant flags: ----O--- -------C
    pop di                              ; compare real flags with correct ones
    and di, 0b_00001000_00000001        ; TODO do not mask flags
    mov si, word [cs:%2 + bp + 4]
    cmp di, si
    jne %%done

    add bp, mul_8_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro


; run the tests
mark 0x60
test_mul_8 mul, mul_8_interesting_set_0
mark 0x61
test_mul_8 mul, mul_8_generic_set_0

mark 0x62
test_mul_8 imul, imul_8_interesting_set_0
mark 0x63
test_mul_8 imul, imul_8_generic_set_0


; generate test data for multiplying two unsigned numbers
%macro mul_8_data 2                    ; op1, op2
    %assign res (%1 * %2) % 0x10000

    ; relevant flags: ----O--- -------C
    %assign flags (res & 0xff00 != 0x0000) ? 0b_00001000_00000001 : 0

    ;%warning %1, %2, res, flags
    db  %1, %2
    dw  res, flags
%endmacro

; generate test data for multiplying two signed numbers
%macro imul_8_data 2                   ; op1, op2
    %assign op1 (%1 < 0x80 ? %1 : %1 - 0x100)
    %assign op2 (%2 < 0x80 ? %2 : %2 - 0x100)
    %assign res (op1 * op2) >= 0 ? (op1 * op2) : (op1 * op2) + 0x10000

    ; relevant flags: ----O--- -------C
    %assign flags ((res & 0xff80) != 0x0000 && (res & 0xff80) != 0xff80) ? 0b_00001000_00000001 : 0

    ;%warning %1, %2, res, flags
    db  %1, %2
    dw  res, flags
%endmacro

mul_8_data_size equ 1 + 1 + 2 + 2       ; op1, op2, res, flags

; test interesting numbers
%macro mul_8_interesting_set 1
    %assign cnt_a 8
    %assign cnt_b 8
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %rep cnt_b
            %assign a %sel(ai, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            %assign b %sel(bi, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            %1_8_data a, b
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; complete test data with/without carry
%macro mul_8_generic_set 1
    %assign step_a 13
    %assign step_b 11
    %assign cnt_a 0x100 / step_a
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

mul_8_interesting_set_0:
    mul_8_interesting_set mul
mul_8_generic_set_0:
    mul_8_generic_set mul
imul_8_interesting_set_0:
    mul_8_interesting_set imul
imul_8_generic_set_0:
    mul_8_generic_set imul
__?SECT?__
