    ; MOV MEM8, REG8 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xab00

    mov [word bx + si + test_ds_16], dh
    mov al, [5 + 11 + test_ds_16]

    mov [word bx + di + test_ds_16], dh
    mov ah, [5 + 13 + test_ds_16]

    mov [word si + test_ds_16], dh
    mov cl, [11 + test_ds_16]

    mov [word di + test_ds_16], dh
    mov ch, [13 + test_ds_16]

    mov [word bx + test_ds_16], dh
    mov dl, [5 + test_ds_16]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xcd00

    mov [word bp + test_ss_16], dh
    mov al, [ss:7 + test_ss_16]

    mov [word bp + si + test_ss_16], dh
    mov ah, [ss:7 + 11 + test_ss_16]

    mov [word bp + di + test_ss_16], dh
    mov cl, [ss:7 + 13 + test_ss_16]

    mov [word test_ds_16], dh
    mov ch, [si - 11 + test_ds_16]

    dump_state
