%include "common.inc"


bss_seg     equ 0x8000

section .bss start=(bss_seg * 0x10)
    resw  7

data:
    resw  1


section .text
    mov dx, 0x1000
    mov ds, dx

    dump_state

%macro clearf 0
    mov di, 0
    push di
    popf
%endmacro

    mark 0x80
%include "shl_b.inc"
;%include "shl_w.inc"

    mark 0x81
%include "shr_b.inc"
;%include "shr_w.inc"

    mark 0x82
%include "sar_b_pos.inc"
;%include "sar_w_pos.inc"

    mark 0x83
%include "sar_b_neg.inc"
;%include "sar_w_neg.inc"

    call power_off
