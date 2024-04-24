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

%macro clearf 0-1 0
    push ax
    mov ax, %1
    push ax
    popf
    pop ax
%endmacro

    mark 0x80
%include "rol_b.inc"
    mark 0x81
%include "rol_w.inc"

    mark 0x88
%include "ror_b.inc"
    mark 0x89
%include "ror_w.inc"

    mark 0x90
%include "rcl_b_c0.inc"
    mark 0x91
%include "rcl_b_c1.inc"
    mark 0x92
%include "rcl_w_c0.inc"
    mark 0x93
%include "rcl_w_c1.inc"

    mark 0x98
%include "rcr_b_c0.inc"
    mark 0x99
%include "rcr_b_c1.inc"
    mark 0x9a
%include "rcr_w_c0.inc"
    mark 0x9b
%include "rcr_w_c1.inc"

    call power_off
