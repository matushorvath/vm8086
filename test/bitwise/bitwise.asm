cpu 8086
org 0x00000


section .data start=0xe0000

    dw  7 dup 0x0000

data:
    dw  0


section .text start=0xd0000
    mov dx, 0x1000
    mov ds, dx

    out 0x42, al

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

    hlt


section boot start=0xffff0              ; boot
    jmp 0xd000:0x0000
