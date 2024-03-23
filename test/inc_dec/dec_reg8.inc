    ; reset the registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov sp, 0
    mov bp, 0
    mov si, 0
    mov di, 0

    ; decrement 8-bit
    dec al
    dec al
    dec al
    dec al
    dec al
    dec al
    dec al
    dec al

    dec ah
    dec ah
    dec ah
    dec ah
    dec ah
    dec ah
    dec ah

    dec bl
    dec bl
    dec bl
    dec bl
    dec bl
    dec bl

    dec bh
    dec bh
    dec bh
    dec bh
    dec bh

    dec cl
    dec cl
    dec cl
    dec cl

    dec ch
    dec ch
    dec ch

    dec dl
    dec dl

    dec dh

    out 0x42, al
