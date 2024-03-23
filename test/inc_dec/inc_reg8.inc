    ; reset the registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov sp, 0
    mov bp, 0
    mov si, 0
    mov di, 0

    ; increment an 8-bit register
    inc al

    inc ah
    inc ah

    inc bl
    inc bl
    inc bl

    inc bh
    inc bh
    inc bh
    inc bh

    inc cl
    inc cl
    inc cl
    inc cl
    inc cl

    inc ch
    inc ch
    inc ch
    inc ch
    inc ch
    inc ch

    inc dl
    inc dl
    inc dl
    inc dl
    inc dl
    inc dl
    inc dl

    inc dh
    inc dh
    inc dh
    inc dh
    inc dh
    inc dh
    inc dh
    inc dh

    out 0x42, al
