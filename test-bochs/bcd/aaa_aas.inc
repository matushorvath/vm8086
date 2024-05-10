; test given instruction and carry flag state against given test set
%macro test_aaa_aas 3                   ; aaa_aas_instruction, af_value, test_set
    mov cx, word [cs:%3]
    mov bp, 2

%%loop:
    mov ah, %2 << 4
    sahf                                ; clear or set auxiliary carry

    mov al, byte [cs:%3 + bp + 0]
    mov bl, al
    mov ah, byte [cs:%3 + bp + 1]
    mov bh, ah
    %1                                  ; execute the operation, src is in BX, dst is in AX
    pushf

    mov dx, word [cs:%3 + bp + 2]
    cmp dx, ax                          ; compare calculated and correct result
    jne %%done

    ; relevant flags: -------- ---A---C
    pop di                              ; compare real flags with correct ones
    and di, 0b_00000000_00010001
    mov si, word [cs:%3 + bp + 4]
    cmp di, si
    jne %%done

    add bp, aaa_aas_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro

; generate test data for the AAA instruction
%macro aaa_data 3                       ; al, ah, af
    %if (%1 & 0x0f) > 9 || %3
        %assign res (%1 + (%2 << 8) + 0x106) & 0xff0f
        %assign flags 0b_00000000_00010001
    %else
        %assign res (%1 + (%2 << 8)) & 0xff0f
        %assign flags 0b_00000000_00000000
    %endif

    ;%warning %1, %2, res, flags
    db  %1, %2
    dw  res, flags
%endmacro

; generate test data for the AAS instruction
%macro aas_data 3                       ; al, ah, af
    %if (%1 & 0x0f) > 9 || %3
        %assign res (%1 + (%2 << 8) - 0x106) & 0xff0f
        %assign flags 0b_00000000_00010001
    %else
        %assign res (%1 + (%2 << 8)) & 0xff0f
        %assign flags 0b_00000000_00000000
    %endif

    ;%warning %1, %2, res, flags
    db  %1, %2
    dw  res, flags
%endmacro

aaa_aas_data_size equ 1 + 1 + 2 + 2     ; op1, op2, res, flags

; test interesting numbers
%macro aaa_aas_interesting_set 2        ; instruction, af
    %assign cnt_a 8
    %assign cnt_b 8
    dw  cnt_a * cnt_b

    %assign ai 1
    %rep cnt_a
        %assign bi 1
        %rep cnt_b
            %assign a %sel(ai, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            %assign b %sel(bi, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)
            %1_data a, b, %2
            %assign bi bi + 1
        %endrep
        %assign ai ai + 1
    %endrep
%endmacro

; test the whole range
%macro aaa_aas_generic_set 2            ; instruction, af
    %assign step_a 13
    %assign step_b 11
    %assign cnt_a 0x100 / step_a
    %assign cnt_b 0x100 / step_b

    dw  cnt_a * cnt_b

    %assign a 0
    %rep cnt_a
        %assign b 0
        %rep cnt_b
            %1_data a, b, %2
            %assign b b + step_b
        %endrep
        %assign a a + step_a
    %endrep
%endmacro


    mark 0x60
    test_aaa_aas aaa, 0, aaa_interesting_set_0
    mark 0x61
    test_aaa_aas aaa, 0, aaa_generic_set_0
    mark 0x62
    test_aaa_aas aaa, 1, aaa_interesting_set_1
    mark 0x63
    test_aaa_aas aaa, 1, aaa_generic_set_1

    mark 0x70
    test_aaa_aas aas, 0, aas_interesting_set_0
    mark 0x71
    test_aaa_aas aas, 0, aas_generic_set_0
    mark 0x72
    test_aaa_aas aas, 1, aas_interesting_set_1
    mark 0x73
    test_aaa_aas aas, 1, aas_generic_set_1


[section .data start=data_addr]

aaa_interesting_set_0:
    aaa_aas_interesting_set aaa, 0
aaa_interesting_set_1:
    aaa_aas_interesting_set aaa, 1

aas_interesting_set_0:
    aaa_aas_interesting_set aas, 0
aas_interesting_set_1:
    aaa_aas_interesting_set aas, 1

aaa_generic_set_0:
    aaa_aas_generic_set aaa, 0
aaa_generic_set_1:
    aaa_aas_generic_set aaa, 1

aas_generic_set_0:
    aaa_aas_generic_set aas, 0
aas_generic_set_1:
    aaa_aas_generic_set aas, 1

__?SECT?__
