    ; MOV MEM16, REG16 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [word bx + si + test_ds_16], sp
    mov ax, [5 + 11 + test_ds_16]

    mov [word bx + di + test_ds_16], sp
    mov cx, [5 + 13 + test_ds_16]

    mov [word si + test_ds_16], sp
    mov dx, [11 + test_ds_16]

    dump_state

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [word di + test_ds_16], cx
    mov ax, [13 + test_ds_16]

    mov [word bx + test_ds_16], cx
    mov dx, [5 + test_ds_16]

    mov [word test_ds_16], cx
    mov sp, [si - 11 + test_ds_16]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [word bp + test_ss_16], dx
    mov ax, [ss:7 + test_ss_16]

    mov [word bp + si + test_ss_16], dx
    mov cx, [ss:7 + 11 + test_ss_16]

    mov [word bp + di + test_ss_16], dx
    mov sp, [ss:7 + 13 + test_ss_16]

    dump_state
