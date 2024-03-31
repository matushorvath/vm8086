    ; MOV MEM8, REG8 (no displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xab00

    mov [bx + si], dh
    mov al, [5 + 11]

    mov [bx + di], dh
    mov ah, [5 + 13]

    mov [si], dh
    mov cl, [11]

    mov [di], dh
    mov ch, [13]

    mov [bx], dh
    mov dl, [5]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xcd00

    mov [bp], dh
    mov al, [ss:7]

    mov [bp + si], dh
    mov ah, [ss:7 + 11]

    mov [bp + di], dh
    mov cl, [ss:7 + 13]

    dump_state
