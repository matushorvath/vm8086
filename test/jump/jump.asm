; TODO CALL NEAR, CALL FAR, RET NEAR IMMED16, RET NEAR 0, RET FAR IMMED16, RET FAR 0 (all immediate)
; TODO CALL NEAR REG16/MEM16, CALL FAR MEM16, JMP NEAR REG16/MEM16, JMP FAR MEM16
; TODO JMP SHORT, JMP NEAR, JMP FAR (all immediate)

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler

%include "conditional.inc"

    hlt


section boot start=0xffff0              ; boot
    int3
