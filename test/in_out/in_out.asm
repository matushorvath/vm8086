cpu 8086
org 0x00000


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    mov al, 0xab
    out 0xcd, al
    out 0x42, al

    mov ax, 0x9876
    out 0xef, ax
    out 0x42, al

    mov al, 0x56
    mov dx, 0x1234
    out dx, al
    out 0x42, al

    mov ax, 0x4567
    mov dx, 0xba98
    out dx, ax
    out 0x42, al

    ; overflow the port number to 00
    mov ax, 0x1234
    mov dx, 0xffff
    out dx, ax
    out 0x42, al

    ; TODO IN AL, IMMED8
    ; TODO IN AX, IMMED8
    ; TODO IN AL, DX
    ; TODO IN AX, DX

    hlt


section boot start=0xffff0              ; boot
    jmp 0xd000:0x0000
