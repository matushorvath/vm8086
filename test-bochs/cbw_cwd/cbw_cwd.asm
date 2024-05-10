%include "common.inc"


section .text
    dump_state

    mov al, 0x00
    cbw
    mov bx, ax

    mov al, 0x45
    cbw
    mov cx, ax

    mov al, 0x7f
    cbw
    mov dx, ax

    mov al, 0x80
    cbw
    mov bp, ax

    mov al, 0xeb
    cbw
    mov si, ax

    mov al, 0xff
    cbw
    mov di, ax

    dump_state

    mov ax, 0x0000
    cwd
    mov bx, ax
    mov cx, dx

    mov ax, 0x4567
    cwd
    mov si, ax
    mov di, dx

    mov ax, 0x7fff
    cwd

    dump_state

    mov ax, 0x8000
    cwd
    mov bx, ax
    mov cx, dx

    mov ax, 0xeb85
    cwd
    mov si, ax
    mov di, dx

    mov ax, 0xffff
    cwd

    dump_state

    call power_off
