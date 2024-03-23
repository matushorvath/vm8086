    ; reset the registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov sp, 0
    mov bp, 0
    mov si, 0
    mov di, 0

    ; increment a 16-bit register
    inc ax

    inc bx
    inc bx

    inc cx
    inc cx
    inc cx

    inc dx
    inc dx
    inc dx
    inc dx

    inc bp
    inc bp
    inc bp
    inc bp
    inc bp

    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp

    inc si
    inc si
    inc si
    inc si
    inc si
    inc si
    inc si

    inc di
    inc di
    inc di
    inc di
    inc di
    inc di
    inc di
    inc di

    out 0x42, al
