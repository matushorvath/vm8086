; XCHG REG16, MEM16

    mov ax, bss_seg
    mov ds, ax
    mov word [ds:data], 0x2468

    mov ax, 0x1111
    mov bx, 0x2222
    mov cx, 0x3333
    mov dx, 0x4444
    mov bp, 0x5555
    mov si, 0x6666
    mov di, 0x7777

    dump_state

    xchg di, [ds:data]

    dump_state

    xchg si, [ds:data]
    xchg bp, [ds:data]
    xchg [ds:data], dx
    xchg [ds:data], cx
    xchg [ds:data], bx
    xchg [ds:data], ax

    dump_state

    ; test sp separately, and make sure we keep the stack working
    mov bx, sp
    mov word [ds:data], 0x1234
    mov sp, 0x9876

    xchg [ds:data], sp
    mov cx, sp              ; cx should be 0x1234 now
    mov dx, word [ds:data]  ; dx should be 0x9876 now

    mov sp, bx

    dump_state
