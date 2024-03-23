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

    out 0x42, al
