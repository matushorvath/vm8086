; TODO test PUSHF/POPF/LAHF/SAHF with flags that can only be set through stack

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; all flags are cleared after boot
    pushf

    ; set/reset individual flags with instructions
    stc
    pushf
    lahf
    out 0x42, al

    sti
    pushf
    lahf
    out 0x42, al

    std
    pushf
    lahf
    out 0x42, al

    clc
    pushf
    lahf
    out 0x42, al

    cli
    pushf
    lahf
    out 0x42, al

    cld
    pushf
    lahf
    out 0x42, al

    cmc
    pushf
    lahf
    out 0x42, al

    cmc
    pushf
    lahf
    out 0x42, al

    ; set all flags, then pop them from stack and verify
    mov dx, 0xffff
    push dx
    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    popf
    out 0x42, al

    hlt


section boot start=0xffff0              ; boot
    int3
