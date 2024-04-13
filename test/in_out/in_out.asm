%include "common.inc"


section .text
    dump_state

    ; test out
    mark 0x80

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

    ; out, overflow the 8-bit port number to 00
    mov ax, 0x5678
    out 0xff, ax
    dump_state

    ; out, overflow the 16-bit port number to 0000
    mov ax, 0x1234
    mov dx, 0xffff
    out dx, ax
    dump_state

    ; test in
    mark 0x81

    mov ax, 0
    in al, 0xcd
    dump_state

    mov ax, 0
    in ax, 0xef
    dump_state

    mov ax, 0
    mov dx, 0x1234
    in al, dx
    dump_state

    mov ax, 0
    mov dx, 0xba98
    in ax, dx
    dump_state

    ; in, overflow the 8-bit port number to 00
    mov ax, 0
    in ax, 0xff
    dump_state

    ; in, overflow the 16-bit port number to 0000
    mov ax, 0
    mov dx, 0xffff
    in ax, dx
    dump_state

    call power_off
