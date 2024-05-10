    ; MOV MEM16, REG16 (no displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [bx + si], sp
    mov ax, [5 + 11]

    mov [bx + di], sp
    mov cx, [5 + 13]

    mov [si], sp
    mov dx, [11]

    dump_state

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [di], cx
    mov ax, [13]

    mov [bx], cx
    mov dx, [5]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [bp], dx
    mov ax, [ss:7]

    mov [bp + si], dx
    mov cx, [ss:7 + 11]

    mov [bp + di], dx
    mov sp, [ss:7 + 13]

    dump_state
