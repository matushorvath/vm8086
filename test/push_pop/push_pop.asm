; TODO PUSH MEM16
; TODO POP REG16/MEM16

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

%include "reg.inc"

    ; the sr.inc test messes up segments
%include "sr.inc"

    hlt


section boot start=0xffff0              ; boot
    int3
