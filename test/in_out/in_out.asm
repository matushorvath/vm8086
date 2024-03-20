cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; TODO when we have mov immediate, output some interesting numbers
    ; TODO use 16-bit numbers with high byte set

    ; TODO OUT AL, IMMED8
    ; TODO OUT AX, IMMED8
    ; TODO OUT AL, DX
    ; TODO OUT AX, DX

    ; TODO IN AL, IMMED8
    ; TODO IN AX, IMMED8
    ; TODO IN AL, DX
    ; TODO IN AX, DX

    hlt


section boot start=0xffff0              ; boot
    int3
