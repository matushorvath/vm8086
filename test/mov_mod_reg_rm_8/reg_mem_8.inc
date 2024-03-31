    ; MOV REG8, MEM8 (8-bit displacement)
    mov ax, 0x0067
    mov cx, 0x0000
    mov dx, 0x0000

    mov [5 + 11 + test_ds_8], al
    mov ah, [byte bx + si + test_ds_8]

    mov [5 + 13 + test_ds_8], al
    mov cl, [byte bx + di + test_ds_8]

    mov [11 + test_ds_8], al
    mov ch, [byte si + test_ds_8]

    mov [13 + test_ds_8], al
    mov dl, [byte di + test_ds_8]

    mov [5 + test_ds_8], al
    mov dh, [byte bx + test_ds_8]

    dump_state

    mov ax, 0x0089
    mov cx, 0x0000
    mov dx, 0x0000

    mov [ss:7 + test_ss_8], al
    mov ah, [byte bp + test_ss_8]

    mov [ss:7 + 11 + test_ss_8], al
    mov cl, [byte bp + si + test_ss_8]

    mov [ss:7 + 13 + test_ss_8], al
    mov ch, [byte bp + di + test_ss_8]

    dump_state
