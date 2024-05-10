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

%include "and_b.inc"
%include "and_w.inc"

    mark 0x81

%include "or_b.inc"
%include "or_w.inc"

    mark 0x82

%include "xor_b.inc"
%include "xor_w.inc"

    mark 0x83

%include "test_b.inc"
%include "test_w.inc"

    mark 0x84
%include "not.inc"

    call power_off
