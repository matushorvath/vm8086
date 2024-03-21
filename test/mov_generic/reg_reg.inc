    ; MOV REG8, REG8
    mov al, 0xab
    mov ah, al
    ; TODO inc ah
    mov bl, ah
    ; TODO inc bl
    mov bh, bl
    ; TODO inc bh
    mov cl, bh
    ; TODO inc cl
    mov ch, cl
    ; TODO inc ch
    mov dl, ch
    ; TODO inc dl
    mov dh, dl
    ; TODO inc dh
    mov al, dh
    ; TODO inc al

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
