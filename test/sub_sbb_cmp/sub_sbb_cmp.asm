; TODO SBB/SUB AL
; TODO SBB/SUB AX
; TODO SBB/SUB from group_immed (8 and 16 bit)

%include "common.inc"


section data_segment start=0x10000 nobits
    resw 29
test_ds_8:
    resw 263
test_ds_16:
    resw 1


section .text
    dump_state

    mov ax, 0x1000
    mov ds, ax

    mark 0x80
%include "sbb_nc_8.inc"
    mark 0x81
%include "sbb_c_8.inc"
    mark 0x82
%include "sub_8.inc"
    mark 0x83
%include "sub_sbb_8_mem.inc"

;     mark 0x90
; %include "sbb_nc_16.inc"
;     mark 0x91
; %include "sbb_c_16.inc"
;     mark 0x92
; %include "sub_16.inc"

; TODO cmp tests

; TODO select specific numbers to test + semi-random selection, don't test the whole range
%include "sub_sbb_cmp_8_all.inc"
%include "sub_sbb_cmp_16_all.inc"

    call power_off


section .data start=data_addr

parity:
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
    db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
