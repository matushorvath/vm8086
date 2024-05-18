    ; MOV REG16, MEM16 (16-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [5 + 11 + test_ds_16], sp
    mov ax, [word bx + si + test_ds_16]

    mov [5 + 13 + test_ds_16], sp
    mov cx, [word bx + di + test_ds_16]

    mov [11 + test_ds_16], sp
    mov dx, [word si + test_ds_16]

    dump_state

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [13 + test_ds_16], cx
    mov ax, [word di + test_ds_16]

    mov [5 + test_ds_16], cx
    mov dx, [word bx + test_ds_16]

    mov [si - 11 + test_ds_16], cx
    mov sp, [word test_ds_16]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [ss:7 + test_ds_16], dx
    mov ax, [word bp + test_ss_16]

    mov [ss:7 + 11 + test_ss_16], dx
    mov cx, [word bp + si + test_ss_16]

    mov [ss:7 + 13 + test_ss_16], dx
    mov sp, [word bp + di + test_ss_16]

    dump_state
