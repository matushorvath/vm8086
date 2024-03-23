cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .data start=0x10000

    dw  7 dup 0x0000

data:
    dw  0


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    mov dx, 0x1000
    mov ds, dx

    out 0x42, al

%macro clearf 0
    mov dx, 0
    push dx
    popf
%endmacro

%include "xor_b.inc"
%include "xor_w.inc"

    hlt


section boot start=0xffff0              ; boot
    int3
