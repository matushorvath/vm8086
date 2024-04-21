; test given instruction and carry flag state against given test set
%macro test_daa_das 2                   ; daa_das_instruction, test_set
    mov cx, word [cs:%2]
    mov bp, 2

%%loop:
    mov al, byte [cs:%2 + bp + 0]       ; set number to process
    mov bl, al
    mov ah, byte [cs:%2 + bp + 2]       ; set input flags
    mov bh, ah
    sahf
    %1                                  ; execute the operation, src is in bl, input flags in bh
    pushf

    mov ah, byte [cs:%2 + bp + 1]
    cmp ah, al                          ; compare calculated and correct result
    jne %%done

    ; relevant flags: -------- ---A---C
    pop dx                              ; compare real flags with correct ones
    and dl, 0b_00010001
    mov dh, byte [cs:%2 + bp + 3]
    cmp dh, dl
    jne %%done

    add bp, daa_das_data_size

    loop %%loop
    xor cx, cx                          ; set ZF = 1

%%done:
    dump_state                          ; successful if ZF is 1
%endmacro

; generate test data for the DAA instruction
%macro daa_data 3                       ; al, cf, af
    %assign reg_AL %1
    %assign flag_CF %2
    %assign flag_AF %3

    %assign in_flags (flag_AF << 4) | (flag_CF << 0)

    %assign old_AL reg_AL
    %assign old_CF flag_CF
    %assign flag_CF 0

    %if (reg_AL & 0x0f) > 9 || flag_AF == 1
        %assign reg_AL reg_AL + 6
        %assign flag_CF old_CF || (reg_AL > 0xff)
        %assign flag_AF 1
        %assign reg_AL reg_AL & 0xff
    %else
        %assign flag_AF 0
    %endif
    %if old_AL > 0x99 || old_CF == 1
        %assign reg_AL (reg_AL + 0x60) % 0x100
        %assign flag_CF 1
    %else
        %assign flag_CF 0
    %endif
    %assign out_flags (flag_AF << 4) | (flag_CF << 0)

    %warning %1, reg_AL, in_flags, out_flags
    db  %1, reg_AL
    db  in_flags, out_flags
%endmacro

; generate test data for the DAS instruction
%macro das_data 3                       ; al, cf, af
    %assign reg_AL %1
    %assign flag_CF %2
    %assign flag_AF %3

    %assign in_flags (flag_AF << 4) | (flag_CF << 0)

    %assign old_AL reg_AL
    %assign old_CF flag_CF
    %assign flag_CF 0

    %if (reg_AL & 0x0f) > 9 || flag_AF == 1
        %assign flag_CF old_CF || (reg_AL < 0x06)
        %assign reg_AL reg_AL - 6
        %assign flag_AF 1
        %assign reg_AL reg_AL & 0xff
    %else
        %assign flag_AF 0
    %endif
    %if old_AL > 0x99 || old_CF == 1
        %assign reg_AL (reg_AL - 0x60) % 0x100
        %assign flag_CF 1
    %endif
    %assign out_flags (flag_AF << 4) | (flag_CF << 0)

    %warning %1, reg_AL, in_flags, out_flags
    db  %1, reg_AL
    db  in_flags, out_flags
%endmacro

daa_das_data_size equ 1 + 1 + 1 + 1     ; op, res, in_flags, out_flags

; test interesting numbers
%macro daa_das_interesting_set 1        ; instruction
    %assign cnt_a 8
    dw  cnt_a * 4

    %assign ai 1
    %rep cnt_a
        %assign a %sel(ai, 0x00, 0x01, 0x7e, 0x7f, 0x80, 0x81, 0xfe, 0xff)

        %1_data a, 0, 0
        %1_data a, 0, 1
        %1_data a, 1, 0
        %1_data a, 1, 1

        %assign ai ai + 1
    %endrep
%endmacro

; test the whole range
%macro daa_das_generic_set 1             ; instruction
    %assign step_a 13
    %assign cnt_a 0x100 / step_a

    dw  cnt_a * 4

    %assign a 0
    %rep cnt_a
        %1_data a, 0, 0
        %1_data a, 0, 1
        %1_data a, 1, 0
        %1_data a, 0, 1
        %assign a a + step_a
    %endrep
%endmacro


    mark 0x80
    test_daa_das daa, daa_interesting_set
    mark 0x81
    test_daa_das daa, daa_generic_set

    mark 0x90
    test_daa_das das, das_interesting_set
    mark 0x91
    test_daa_das das, das_generic_set


[section .data start=data_addr]

daa_interesting_set:
    daa_das_interesting_set daa
daa_generic_set:
    daa_das_generic_set daa

das_interesting_set:
    daa_das_interesting_set das
das_generic_set:
    daa_das_generic_set das

__?SECT?__
