    ; MOV REG8, MEM8 (16-bit displacement)
    mov ax, 0x0067
    mov cx, 0x0000
    mov dx, 0x0000

    mov [5 + 11 + test_ds_16], al
    mov ah, [word bx + si + test_ds_16]

    mov [5 + 13 + test_ds_16], al
    mov cl, [word bx + di + test_ds_16]

    mov [11 + test_ds_16], al
    mov ch, [word si + test_ds_16]

    mov [13 + test_ds_16], al
    mov dl, [word di + test_ds_16]

    mov [5 + test_ds_16], al
    mov dh, [word bx + test_ds_16]

    dump_state

    mov ax, 0x0089
    mov cx, 0x0000
    mov dx, 0x0000

    mov [ss:7 + test_ss_16], al
    mov ah, [word bp + test_ss_16]

    mov [ss:7 + 11 + test_ss_16], al
    mov cl, [word bp + si + test_ss_16]

    mov [ss:7 + 13 + test_ss_16], al
    mov ch, [word bp + di + test_ss_16]

    mov [si - 11 + test_ds_16], al
    mov dl, [word test_ds_16]

    dump_state
