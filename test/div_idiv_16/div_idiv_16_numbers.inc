; DIV/IDIV 16-bit
    mov ax, 0
    mov bx, 0
    mov dx, 0
    mov si, 0
    mov di, 0

; test given instruction and carry flag state against given test set
%macro test_div_16 2                     ; div_instruction, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov al, byte [cs:%2 + bp + 6]
    xor ah, ah
    mov si, ax

    mov ax, word [cs:%2 + bp + 0]
    mov dx, word [cs:%2 + bp + 2]
    mov bx, word [cs:%2 + bp + 4]

    clc
    %1  bx                              ; ax,dx = dx:ax OP bx
    jc  %%divide_error

    ; was division supposed to pass without an interrupt?
    test si, si
    jnz %%done

    mov di, word [cs:%2 + bp + 7]
    cmp di, ax                          ; compare calculated and correct result
    jne %%done

    mov si, word [cs:%2 + bp + 9]
    cmp si, dx
    jne %%done

    jmp %%next

%%divide_error:
    ; was the division supposed to fail?
    test si, si
    jnz %%next
    cmp cx, 0x00                        ; set ZF = 0

%%next:
    add bp, div_16_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro


; run the tests
mark 0x60
test_div_16 div, div_16_interesting_set
mark 0x61
test_div_16 div, div_16_generic_set

; TODO enable
; mark 0x62
; test_div_16 idiv, idiv_16_interesting_set
; mark 0x63
; test_div_16 idiv, idiv_16_generic_set


; generate test data for dividing two unsigned numbers
%macro div_16_data 2                    ; op1, op2
    %assign res 0x0000
    %assign mod 0x0000

    %if %2 == 0
        %assign de 1
    %else
        %if (%1 / %2) > 0xffff
            %assign de 1
        %else
            %assign res (%1 / %2) & 0xffff
            %assign mod (%1 % %2)
            %assign de 0
        %endif
    %endif

    ;%warning %1, %2, de, res, mod
    dd  %1
    dw  %2
    db  de
    dw  res, mod
%endmacro

; TODO enable
; generate test data for dividing two signed numbers
; %macro idiv_16_data 2                   ; op1, op2
;     %assign op1 (%1 < 0x80 ? %1 : %1 - 0x100)
;     %assign op2 (%2 < 0x80 ? %2 : %2 - 0x100)
;     %assign res (op1 * op2) >= 0 ? (op1 * op2) : (op1 * op2) + 0x10000

;     ; relevant flags: ----O--- -------C
;     %assign flags ((res & 0xff80) != 0x0000 && (res & 0xff80) != 0xff80) ? 0b_00001000_00000001 : 0

;     ;%warning %1, %2, res, flags
;     db  %1, %2
;     dw  res, flags
; %endmacro

div_16_data_size equ 4 + 2 + 1 + 2 + 2   ; op1, op2, de, res, mod

; test interesting numbers
%macro make_div_16_interesting_set 1
    %assign cnt_a 26
    %assign cnt_b 20
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %rep cnt_b
            %assign a %sel(ai, \
                0x00000000, 0x00000001, 0x0000007e, 0x0000007f, 0x00000080, 0x00000081, 0x000000fe, 0x000000ff, 0x00000100, 0x00000101, \
                0x0000017e, 0x0000017f, 0x00000180, 0x00000181, 0x00007ffe, 0x00007fff, 0x00008000, 0x00008001, 0x0000fffe, 0x0000ffff, \
                0x7ffffffe, 0x7fffffff, 0x80000000, 0x80000001, 0xfffffffe, 0xffffffff)
            %assign b %sel(bi, 0x0000, 0x0001, 0x007e, 0x007f, 0x0080, 0x0081, 0x00fe, 0x00ff, 0x0100, 0x0101, \
                0x017e, 0x017f, 0x0180, 0x0181, 0x7ffe, 0x7fff, 0x8000, 0x8001, 0xfffe, 0xffff)
            %1_16_data a, b
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; complete test data with/without carry
%macro make_div_16_generic_set 1
    %assign step_a 200000033
    %assign step_b 3271
    %assign cnt_a 0x10000000 / step_a
    %assign cnt_b 0x1000 / step_b

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

div_16_interesting_set:
    make_div_16_interesting_set div
div_16_generic_set:
    make_div_16_generic_set div
; idiv_16_interesting_set:
;     make_div_16_interesting_set idiv
; idiv_16_generic_set:
;     make_div_16_generic_set idiv

__?SECT?__
