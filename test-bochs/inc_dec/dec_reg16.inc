    ; save SP
    mov word [orig_sp], sp

    ; reset the registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov sp, 0
    mov bp, 0
    mov si, 0
    mov di, 0

    ; decrement a 16-bit register
    dec di

    dec si
    dec si

    dec sp
    dec sp
    dec sp

    dec bp
    dec bp
    dec bp
    dec bp

    dec dx
    dec dx
    dec dx
    dec dx
    dec dx

    dec cx
    dec cx
    dec cx
    dec cx
    dec cx
    dec cx

    dec bx
    dec bx
    dec bx
    dec bx
    dec bx
    dec bx
    dec bx

    dec ax
    dec ax
    dec ax
    dec ax
    dec ax
    dec ax
    dec ax
    dec ax

    ; clear stack that will be visible in dump, because it differs between bochs and vm8086
    times 8 pushf

    dump_state

    ; restore SP
    mov sp, word [orig_sp]
