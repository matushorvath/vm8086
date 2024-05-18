%include "common.inc"


section .text
    mark 0x80

    ; output 'Shutdowx' to port 0x8900, the incorrect string
    ; TODO use outsb once available
    mov dx, 0x8900
    mov si, 0x00

loop_char:
    mov al, [cs:shutdowx_string + si]
    cmp al, 0x00
    je  loop_done

    out dx, al
    inc si
    jmp loop_char

loop_done:

    mark 0x81

    ; call the proper power off implementation
    call power_off

    ; this mark should not be reached
    mark 0xff
    jmp $

shutdowx_string:
    db  "Shutdowx", 0
