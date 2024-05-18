; test the aad instruction
%macro test_aad 2                       ; base, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov ax, word [cs:%2 + bp + 0]
    mov bx, ax

    ; encode the aad instruction with the second byte taken from bh
    db  0xd5                            ; d5 = opcode of aad
    db  %1                              ; base
    pushf

    mov dl, byte [cs:%2 + bp + 2]
    cmp dl, al                          ; compare calculated and correct result
    jne %%done

    ; relevant flags: -------- SZ---P--
    pop di                              ; compare real flags with correct ones
    and di, 0b_00000000_11000100
    mov si, word [cs:%2 + bp + 3]
    cmp di, si
    jne %%done

    add bp, aad_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro

; generate test data for the AAA instruction
%macro aad_data 3                       ; al, ah, base
    %assign new_al (%1 + %2 * %3) & 0xff

    %assign sfl new_al >= 0x80 ? 0b_00000000_10000000 : 0
    %assign zfl new_al == 0 ? 0b_00000000_01000000 : 0
    %assign pfl (\
            (new_al & 0x80 != 0) + (new_al & 0x40 != 0) + (new_al & 0x20 != 0) + (new_al & 0x10 != 0) + \
            (new_al & 0x08 != 0) + (new_al & 0x04 != 0) + (new_al & 0x02 != 0) + (new_al & 0x01 != 0) \
        ) % 2 == 0 ? 0b_00000000_00000100 : 0
    %assign flags sfl | zfl | pfl

    ;%warning %1, new_al, new_ah, flags
    db  %1, %2, new_al
    dw  flags
%endmacro

aad_data_size equ 2 + 1 + 2     ; %1, %2, new_al, flags

; test interesting numbers
%macro make_aad_interesting_set 1       ; base
    %assign cnt_a 16
    %assign cnt_b 16
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %assign a %sel(ai, \
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, \
            0x09, 0x0a, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
        %rep cnt_b
            %assign b %sel(bi, \
                0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, \
                0x09, 0x0a, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            aad_data a, b, %1
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; test the whole range
%macro make_aad_generic_set 1           ; base
    %assign step_a 3271
    %assign cnt_a 0x10000 / step_a

    dw  cnt_a

    %assign a 0
    %rep cnt_a
        aad_data (a % 0xff), (a / 0xff), %1
        %assign a a + step_a
    %endrep
%endmacro


; TODO test with base = 0

    mark 0xb0
    test_aad 10, aad_interesting_set_10
    mark 0xb1
    test_aad 1, aad_generic_set_01
    mark 0xb2
    test_aad 2, aad_generic_set_02
    mark 0xba
    test_aad 10, aad_generic_set_10
    mark 0xbf
    test_aad 16, aad_generic_set_16
    mark 0xb7
    test_aad 0x7f, aad_generic_set_7f


[section .data start=data_addr]

aad_interesting_set_10:
    make_aad_interesting_set 10
aad_generic_set_01:
    make_aad_generic_set 1
aad_generic_set_02:
    make_aad_generic_set 2
aad_generic_set_10:
    make_aad_generic_set 10
aad_generic_set_16:
    make_aad_generic_set 16
aad_generic_set_7f:
    make_aad_generic_set 0x7f

__?SECT?__
