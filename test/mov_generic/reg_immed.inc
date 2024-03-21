    ; MOV REG, IMMED8
    mov al, 0x01
    mov ah, 0x12
    mov bl, 0x23
    mov bh, 0x34
    mov cl, 0x45
    mov ch, 0x56
    mov dl, 0x67
    mov dh, 0x78

    out 0x42, al

    ; MOV REG, IMMED16
    mov ax, 0xfedc
    mov bx, 0xedcb
    mov cx, 0xba98
    mov dx, 0xa987
    mov sp, 0x7654                      ; breaks stack
    mov bp, 0x6543
    mov si, 0x3210
    mov di, 0x210f

    out 0x42, al
