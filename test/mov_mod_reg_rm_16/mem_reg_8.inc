    ; MOV MEM16, REG16 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [byte bx + si + test_ds], sp
    mov ax, [5 + 11 + test_ds]

    mov [byte bx + di + test_ds], sp
    mov cx, [5 + 13 + test_ds]

    mov [byte si + test_ds], sp
    mov dx, [11 + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [byte di + test_ds], cx
    mov ax, [13 + test_ds]

    mov [byte bx + test_ds], cx
    mov dx, [5 + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [byte bp + test_ss], dx
    mov ax, [ss:7 + test_ss]

    mov [byte bp + si + test_ss], dx
    mov cx, [ss:7 + 11 + test_ss]

    mov [byte bp + di + test_ss], dx
    mov sp, [ss:7 + 13 + test_ss]

    out 0x42, al
