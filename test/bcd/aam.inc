; test the aam instruction
%macro test_aam 2                       ; base, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov al, byte [cs:%2 + bp + 0]
    mov bl, al
    mov bh, %2

    ; encode the aam instruction with the second byte taken from bh
    db  0xd4                            ; d4 = opcode of aam
    db  %1                              ; base
    pushf

    mov dx, word [cs:%2 + bp + 2]
    cmp dx, ax                          ; compare calculated and correct result
    jne %%done

    ; relevant flags: -------- SZ---P--
    pop di                              ; compare real flags with correct ones
    and di, 0b_00000000_11000100
    mov si, word [cs:%2 + bp + 4]
    cmp di, si
    jne %%done

    mov al, '.'
    out 0xe9, al

    add bp, aam_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro

; generate test data for the AAA instruction
%macro aam_data 2                       ; al, base
    ; TODO handle %2 == 0 (division by zero)
    %assign new_al (%1 / %2)
    %assign new_ah (%1 % %2)

    %assign sfl new_al >= 0x80 ? 0b_00000000_10000000 : 0
    %assign zfl new_al == 0 ? 0b_00000000_01000000 : 0
    %assign pfl (\
            (new_al & 0x80 != 0) + (new_al & 0x40 != 0) + (new_al & 0x20 != 0) + (new_al & 0x10 != 0) + \
            (new_al & 0x08 != 0) + (new_al & 0x04 != 0) + (new_al & 0x02 != 0) + (new_al & 0x01 != 0) \
        ) % 2 == 0 ? 0b_00000000_00000100 : 0
    %assign flags sfl | zfl | pfl

    ;%warning %1, %2, new_al, new_ah, flags
    db  %1, new_al, new_ah
    dw  flags
%endmacro

aam_data_size equ 1 + 1 + 1 + 2     ; %1, new_al, new_ah, flags

; test interesting numbers
%macro make_aam_interesting_set 1       ; base
    %assign cnt_a 16
    dw  cnt_a

    %assign ai 1
    %rep cnt_a
        %assign a %sel(ai, \
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, \
            0x09, 0x0a, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
        aam_data a, %1
        %assign ai ai + 1
    %endrep
%endmacro

; test the whole range
%macro make_aam_generic_set 1           ; base
    %assign step_a 7
    %assign cnt_a 0x100 / step_a

    dw  cnt_a

    %assign a 0
    %rep cnt_a
        aam_data a, %1
        %assign a a + step_a
    %endrep
%endmacro


; TODO test with base = 0

    mark 0xa0
    test_aam 10, aam_interesting_set_10
    mark 0xa1
    test_aam 1, aam_generic_set_01
    mark 0xa2
    test_aam 2, aam_generic_set_02
    mark 0xaa
    test_aam 10, aam_generic_set_10
    mark 0xaf
    test_aam 16, aam_generic_set_16
    mark 0xa7
    test_aam 0x7f, aam_generic_set_7f


[section .data start=data_addr]

aam_interesting_set_10:
    make_aam_interesting_set 10
aam_generic_set_01:
    make_aam_generic_set 1
aam_generic_set_02:
    make_aam_generic_set 2
aam_generic_set_10:
    make_aam_generic_set 10
aam_generic_set_16:
    make_aam_generic_set 16
aam_generic_set_7f:
    make_aam_generic_set 0x7f

__?SECT?__
