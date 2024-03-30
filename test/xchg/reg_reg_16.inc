; XCHG REG16, REG16

    mov ax, 0x1111
    mov bx, 0x2222
    mov cx, 0x3333
    mov dx, 0x4444
    mov bp, 0x5555
    mov si, 0x6666
    mov di, 0x7777

    dump_state

    xchg di, si

    dump_state

    xchg si, bp
    xchg bp, dx
    xchg dx, cx
    xchg cx, bx
    xchg bx, ax
    xchg di, ax

    dump_state

    ; test sp separately, and make sure we keep the stack working
    mov bx, sp
    mov dx, 0x1234
    mov sp, 0x9876

    xchg dx, sp
    mov cx, sp              ; cx should be 0x1234 now

    mov sp, bx

    dump_state
