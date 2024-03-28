cpu 8086
org 0x00000


section .data start=0xe0000
    dw  13 dup (0)
data:
    dw  0


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    out 0x42, al

%include "reg.inc"
%include "mem.inc"

    ; the sr.inc test messes up segments
%include "sr.inc"

    hlt


section boot start=0xffff0              ; boot
    jmp 0xd000:0x0000
