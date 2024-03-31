    ; MOV MEM8, REG8 (8-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xab00

    mov [byte bx + si + test_ds_8], dh
    mov al, [5 + 11 + test_ds_8]

    mov [byte bx + di + test_ds_8], dh
    mov ah, [5 + 13 + test_ds_8]

    mov [byte si + test_ds_8], dh
    mov cl, [11 + test_ds_8]

    mov [byte di + test_ds_8], dh
    mov ch, [13 + test_ds_8]

    mov [byte bx + test_ds_8], dh
    mov dl, [5 + test_ds_8]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xcd00

    mov [byte bp + test_ss_8], dh
    mov al, [ss:7 + test_ss_8]

    mov [byte bp + si + test_ss_8], dh
    mov ah, [ss:7 + 11 + test_ss_8]

    mov [byte bp + di + test_ss_8], dh
    mov cl, [ss:7 + 13 + test_ss_8]

    dump_state
