    ; MOV REG8, MEM8 (8-bit displacement)
    mov ax, 0x0067
    mov cx, 0x0000
    mov dx, 0x0000

    mov [5 + 11], al
    mov ah, [byte bx + si]

    mov [5 + 13], al
    mov cl, [byte bx + di]

    mov [11], al
    mov ch, [byte si]

    mov [13], al
    mov dl, [byte di]

    mov [5], al
    mov dh, [byte bx]

    dump_state

    mov ax, 0x0089
    mov cx, 0x0000
    mov dx, 0x0000

    mov [ss:7], al
    mov ah, [byte bp]

    mov [ss:7 + 11], al
    mov cl, [byte bp + si]

    mov [ss:7 + 13], al
    mov ch, [byte bp + di]

    dump_state
