    ; MOV REG16, MEM16 (8-bit displacement)
    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x0000
    mov sp, 0xabcd

    mov [5 + 11], sp
    mov ax, [byte bx + si]

    mov [5 + 13], sp
    mov cx, [byte bx + di]

    mov [11], sp
    mov dx, [byte si]

    dump_state

    mov ax, 0x0000
    mov cx, 0x5432
    mov dx, 0x0000
    mov sp, 0x0000

    mov [13], cx
    mov ax, [byte di]

    mov [5], cx
    mov dx, [byte bx]

    dump_state

    mov ax, 0x0000
    mov cx, 0x0000
    mov dx, 0x789a
    mov sp, 0x0000

    mov [ss:7], dx
    mov ax, [byte bp]

    mov [ss:7 + 11], dx
    mov cx, [byte bp + si]

    mov [ss:7 + 13], dx
    mov sp, [byte bp + di]

    dump_state
