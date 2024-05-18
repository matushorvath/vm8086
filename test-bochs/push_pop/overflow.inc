    ; test push when stack is close to segment boundary
    mov dx, sp

    ; near lower boundary of stack segment
    mov sp, 0x0002

    mov ax, 0x2468
    push ax
    mov ax, 0x3579
    push ax
    dump_state

    pop bx
    pop cx
    dump_state

    ; clear the stack

    ; near upper boundary of stack segment
    mov sp, 0xfffe

    ; write meaningful values to the stack
    mov bp, sp
    mov word [bp + 0], 0xabcd
    mov word [bp + 2], 0xfedc

    pop bx
    pop cx
    dump_state

    mov ax, 0x8642
    push ax
    mov ax, 0x9753
    push ax
    dump_state

    ; restore SP and clear registers into a known state
    mov sp, dx

    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0
