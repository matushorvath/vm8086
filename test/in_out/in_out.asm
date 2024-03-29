%include "common.inc"


section .text
    dump_state

    mov al, 0xab
    out 0xcd, al
    dump_state

    mov ax, 0x9876
    out 0xef, ax
    dump_state

    mov al, 0x56
    mov dx, 0x1234
    out dx, al
    dump_state

    mov ax, 0x4567
    mov dx, 0xba98
    out dx, ax
    dump_state

    ; overflow the port number to 00
    mov ax, 0x1234
    mov dx, 0xffff
    out dx, ax
    dump_state

    ; TODO IN AL, IMMED8
    ; TODO IN AX, IMMED8
    ; TODO IN AL, DX
    ; TODO IN AX, DX

    hlt
