    ; MOV MEM8, REG8 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xab00

    mov [word bx + si + test_ds], dh
    mov al, [5 + 11 + test_ds]

    mov [word bx + di + test_ds], dh
    mov ah, [5 + 13 + test_ds]

    mov [word si + test_ds], dh
    mov cl, [11 + test_ds]

    mov [word di + test_ds], dh
    mov ch, [13 + test_ds]

    mov [word bx + test_ds], dh
    mov dl, [5 + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0xcd00

    ; TODO needs segment overrride
    ; mov [word bp + test_ss], dh
    ; mov al, [ss:7 + test_ds]

    ; TODO needs segment overrride
    ; mov [word bp + si + test_ss], dh
    ; mov ah, [ss:7 + 11 + test_ss]

    ; TODO needs segment overrride
    ; mov [word bp + di + test_ss], dh
    ; mov cl, [ss:7 + 13 + test_ss]

    mov [word test_ds], dh
    mov ch, [si - 11 + test_ds]

    out 0x42, al
