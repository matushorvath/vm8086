    ; MOV REG8, MEM8 (16-bit displacement)
    mov ax, 0x0067
    mov cx, 0x0000
    mov dx, 0x0000

    mov [5 + 11 + test_ds], al
    mov ah, [word bx + si + test_ds]

    mov [5 + 13 + test_ds], al
    mov cl, [word bx + di + test_ds]

    mov [11 + test_ds], al
    mov ch, [word si + test_ds]

    mov [13 + test_ds], al
    mov dl, [word di + test_ds]

    mov [5 + test_ds], al
    mov dh, [word bx + test_ds]

    dump_state

    mov ax, 0x0089
    mov cx, 0x0000
    mov dx, 0x0000

    mov [ss:7 + test_ss], al
    mov ah, [word bp + test_ss]

    mov [ss:7 + 11 + test_ss], al
    mov cl, [word bp + si + test_ss]

    mov [ss:7 + 13 + test_ss], al
    mov ch, [word bp + di + test_ss]

    mov [si - 11 + test_ds], al
    mov dl, [word test_ds]

    dump_state
