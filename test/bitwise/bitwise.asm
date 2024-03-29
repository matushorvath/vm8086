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

    out 0x80, al

%include "and_b.inc"
%include "and_w.inc"

    out 0x81, al

%include "or_b.inc"
%include "or_w.inc"

    out 0x82, al

%include "xor_b.inc"
%include "xor_w.inc"

    out 0x83, al

%include "test_b.inc"
%include "test_w.inc"

    call power_off
