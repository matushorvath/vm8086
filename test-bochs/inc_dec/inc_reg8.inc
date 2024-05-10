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

    ; increment an 8-bit register
    inc al

    inc ah
    inc ah

    inc bl
    inc bl
    inc bl

    inc bh
    inc bh
    inc bh
    inc bh

    inc cl
    inc cl
    inc cl
    inc cl
    inc cl

    inc ch
    inc ch
    inc ch
    inc ch
    inc ch
    inc ch

    inc dl
    inc dl
    inc dl
    inc dl
    inc dl
    inc dl
    inc dl

    inc dh
    inc dh
    inc dh
    inc dh
    inc dh
    inc dh
    inc dh
    inc dh

    ; clear stack that will be visible in dump, because it differs between bochs and vm8086
    times 8 pushf

    dump_state

    ; restore SP
    mov sp, word [orig_sp]
