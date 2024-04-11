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
    push ax
    mov ax, 0
    push ax
    popf
    pop ax
%endmacro

    mark 0x80
%include "shl_b.inc"
    mark 0x81
%include "shl_w.inc"
    mark 0x82
%include "shr_b.inc"
    mark 0x83
;%include "shr_w.inc"
    mark 0x84
%include "sar_b_pos.inc"
    mark 0x85
;%include "sar_w_pos.inc"
    mark 0x86
%include "sar_b_neg.inc"
    mark 0x87
;%include "sar_w_neg.inc"

    call power_off
