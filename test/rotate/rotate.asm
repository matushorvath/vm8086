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
%include "rol_b.inc"
    mark 0x81
;%include "rol_w.inc"
    mark 0x82
;%include "ror_b.inc"
    mark 0x83
;%include "ror_w.inc"

    call power_off
