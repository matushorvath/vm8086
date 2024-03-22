    ; MOV MEM16, REG16 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [word bx + si + test_ds], sp
    mov ax, [5 + 11 + test_ds]

    mov [word bx + di + test_ds], sp
    mov cx, [5 + 13 + test_ds]

    mov [word si + test_ds], sp
    mov dx, [11 + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [word di + test_ds], cx
    mov ax, [13 + test_ds]

    mov [word bx + test_ds], cx
    mov dx, [5 + test_ds]

    mov [word test_ds], cx
    mov sp, [si - 11 + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [word bp + test_ss], dx
    mov ax, [ss:7 + test_ss]

    mov [word bp + si + test_ss], dx
    mov cx, [ss:7 + 11 + test_ss]

    mov [word bp + di + test_ss], dx
    mov sp, [ss:7 + 13 + test_ss]

    out 0x42, al
