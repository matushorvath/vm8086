    ; MOV REG16, MEM16 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [5 + 11 + test_ds], sp
    mov ax, [word bx + si + test_ds]

    mov [5 + 13 + test_ds], sp
    mov cx, [word bx + di + test_ds]

    mov [11 + test_ds], sp
    mov dx, [word si + test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [13 + test_ds], cx
    mov ax, [word di + test_ds]

    mov [5 + test_ds], cx
    mov dx, [word bx + test_ds]

    mov [si - 11 + test_ds], cx
    mov sp, [word test_ds]

    out 0x42, al

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    ; TODO needs segment overrride
    ; mov [ss:7 + test_ds], dx
    ; mov ax, [word bp + test_ss]

    ; TODO needs segment overrride
    ; mov [ss:7 + 11 + test_ss], dx
    ; mov cx, [word bp + si + test_ss]

    ; TODO needs segment overrride
    ; mov [ss:7 + 13 + test_ss], dx
    ; mov sp, [word bp + di + test_ss]

    out 0x42, al
