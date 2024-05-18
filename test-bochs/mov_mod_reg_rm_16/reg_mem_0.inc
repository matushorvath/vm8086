    ; MOV REG16, MEM16 (no displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [5 + 11], sp
    mov ax, [bx + si]

    mov [5 + 13], sp
    mov cx, [bx + di]

    mov [11], sp
    mov dx, [si]

    dump_state

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [13], cx
    mov ax, [di]

    mov [5], cx
    mov dx, [bx]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [ss:7], dx
    mov ax, [bp]

    mov [ss:7 + 11], dx
    mov cx, [bp + si]

    mov [ss:7 + 13], dx
    mov sp, [bp + di]

    dump_state
