    ; MOV REG8, MEM8 (no displacement)
    mov ax, 0x0067
    mov cx, 0x0000
    mov dx, 0x0000

    mov [5 + 11], al
    mov ah, [bx + si]

    mov [5 + 13], al
    mov cl, [bx + di]

    mov [11], al
    mov ch, [si]

    mov [13], al
    mov dl, [di]

    mov [5], al
    mov dh, [bx]

    dump_state

    mov ax, 0x0089
    mov cx, 0x0000
    mov dx, 0x0000

    mov [ss:7], al
    mov ah, [bp]

    mov [ss:7 + 11], al
    mov cl, [bp + si]

    mov [ss:7 + 13], al
    mov ch, [bp + di]

    dump_state
