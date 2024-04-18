; MUL/IMUL 16-bit
    mov ax, 0
    mov bx, 0
    mov dx, 0
    mov si, 0
    mov di, 0

; test given instruction and carry flag state against given test set
%macro test_mul_16 2                     ; mul_instruction, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov ax, word [cs:%2 + bp + 0]
    mov es, ax
    mov bx, word [cs:%2 + bp + 2]
    %1  bx                              ; dx:ax = es OP bx
    pushf

    mov di, word [cs:%2 + bp + 4]
    cmp di, ax                          ; compare calculated and correct result
    jne %%done

    mov di, word [cs:%2 + bp + 6]
    cmp di, dx
    jne %%done

    ; relevant flags: ----O--- -------C
    pop di                              ; compare real flags with correct ones
    and di, 0b_00001000_00000001        ; TODO do not mask flags
    mov si, word [cs:%2 + bp + 8]
    cmp di, si
    jne %%done

    add bp, mul_16_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro


; run the tests
mark 0x60
test_mul_16 mul, mul_16_interesting_set_0
mark 0x61
test_mul_16 mul, mul_16_generic_set_0

mark 0x62
test_mul_16 imul, imul_16_interesting_set_0
mark 0x63
test_mul_16 imul, imul_16_generic_set_0


; generate test data for multiplying two unsigned numbers
%macro mul_16_data 2                    ; op1, op2
    %assign res (%1 * %2) % 0x100000000

    ; relevant flags: ----O--- -------C
    %assign flags (res & 0xffff0000 != 0) ? 0b_00001000_00000001 : 0

    ;%warning %1, %2, res, flags
    dw  %1, %2
    dd  res
    dw  flags
%endmacro

; generate test data for multiplying two signed numbers
%macro imul_16_data 2                   ; op1, op2
    %assign op1 (%1 < 0x8000 ? %1 : %1 - 0x10000)
    %assign op2 (%2 < 0x8000 ? %2 : %2 - 0x10000)
    %assign res (op1 * op2) >= 0 ? (op1 * op2) : (op1 * op2) + 0x100000000

    ; relevant flags: ----O--- -------C
    %assign flags ((res & 0xffff8000) != 0x00000000 && (res & 0xffff8000) != 0xffff8000) ? 0b_00001000_00000001 : 0

    ;%warning %1, %2, res, flags
    dw  %1, %2
    dd  res
    dw  flags
%endmacro

mul_16_data_size equ 2 + 2 + 4 + 2       ; op1, op2, res, flags

; test interesting numbers
%macro mul_16_interesting_set 1
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
            %1_16_data a, b
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; complete test data with/without carry
%macro mul_16_generic_set 1
    %assign step_a 3271
    %assign step_b 3259
    %assign cnt_a 0x10000 / step_a
    %assign cnt_b 0x10000 / step_b

    dw  cnt_a * cnt_b

    %assign a 0
    %rep cnt_a
        %assign b 0
        %rep cnt_b
            %1_16_data a, b
            %assign b b + step_b
        %endrep
        %assign a a + step_a
    %endrep
%endmacro


[section .data start=data_addr]

mul_16_interesting_set_0:
    mul_16_interesting_set mul
mul_16_generic_set_0:
    mul_16_generic_set mul
imul_16_interesting_set_0:
    mul_16_interesting_set imul
imul_16_generic_set_0:
    mul_16_generic_set imul
__?SECT?__
