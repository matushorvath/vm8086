    ; MOV MEM16, REG16 (8-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [byte bx + si + test_ds_8], sp
    mov ax, [5 + 11 + test_ds_8]

    mov [byte bx + di + test_ds_8], sp
    mov cx, [5 + 13 + test_ds_8]

    mov [byte si + test_ds_8], sp
    mov dx, [11 + test_ds_8]

    dump_state

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [byte di + test_ds_8], cx
    mov ax, [13 + test_ds_8]

    mov [byte bx + test_ds_8], cx
    mov dx, [5 + test_ds_8]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [byte bp + test_ss_8], dx
    mov ax, [ss:7 + test_ss_8]

    mov [byte bp + si + test_ss_8], dx
    mov cx, [ss:7 + 11 + test_ss_8]

    mov [byte bp + di + test_ss_8], dx
    mov sp, [ss:7 + 13 + test_ss_8]

    dump_state
