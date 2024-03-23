    ; MOV REG8, REG8
    mov al, 0xab
    mov ah, al
    inc ah
    mov bl, ah
    inc bl
    mov bh, bl
    inc bh
    mov cl, bh
    inc cl
    mov ch, cl
    inc ch
    mov dl, ch
    inc dl
    mov dh, dl
    inc dh
    mov al, dh
    inc al

    out 0x42, al

    ; MOV REG16, REG16
    mov ax, 0x4321
    mov bx, ax
    inc bx
    mov cx, bx
    inc cx
    mov dx, cx
    inc dx
    mov sp, dx                          ; breaks stack
    inc sp
    mov bp, sp
    inc bp
    mov si, bp
    inc si
    mov di, si
    inc di
    mov ax, di
    inc ax

    out 0x42, al
