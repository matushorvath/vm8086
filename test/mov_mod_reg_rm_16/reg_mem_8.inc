    ; MOV REG16, MEM16 (8-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [5 + 11 + test_ds], sp
    mov ax, [byte bx + si + test_ds]

    mov [5 + 13 + test_ds], sp
    mov cx, [byte bx + di + test_ds]

    mov [11 + test_ds], sp
    mov dx, [byte si + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [13 + test_ds], cx
    mov ax, [byte di + test_ds]

    mov [5 + test_ds], cx
    mov dx, [byte bx + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [ss:7 + test_ds], dx
    mov ax, [byte bp + test_ss]

    mov [ss:7 + 11 + test_ss], dx
    mov cx, [byte bp + si + test_ss]

    mov [ss:7 + 13 + test_ss], dx
    mov sp, [byte bp + di + test_ss]

    out 0x42, al
