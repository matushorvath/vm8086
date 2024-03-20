cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; all flags are cleared after boot

    stc
    out 0x42, al

    sti
    out 0x42, al

    std
    out 0x42, al

    clc
    out 0x42, al

    cli
    out 0x42, al

    cld
    out 0x42, al

    cmc
    out 0x42, al

    cmc
    out 0x42, al

    ; TODO PUSHF after every change
    ; TODO POPF to set each flag individually

    hlt


section boot start=0xffff0              ; boot
    int3
