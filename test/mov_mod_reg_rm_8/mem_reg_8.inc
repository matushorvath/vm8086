    ; MOV MEM8, REG8 (8-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xab00

    mov [byte bx + si + test_ds], dh
    mov al, [5 + 11 + test_ds]

    mov [byte bx + di + test_ds], dh
    mov ah, [5 + 13 + test_ds]

    mov [byte si + test_ds], dh
    mov cl, [11 + test_ds]

    mov [byte di + test_ds], dh
    mov ch, [13 + test_ds]

    mov [byte bx + test_ds], dh
    mov dl, [5 + test_ds]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xcd00

    mov [byte bp + test_ss], dh
    mov al, [ss:7 + test_ss]

    mov [byte bp + si + test_ss], dh
    mov ah, [ss:7 + 11 + test_ss]

    mov [byte bp + di + test_ss], dh
    mov cl, [ss:7 + 13 + test_ss]

    dump_state
