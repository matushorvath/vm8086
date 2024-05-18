    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 8-bit
    mov bl, 0b_10110010
    not bl                              ; NOT REG16

    mov byte [data], 0b_10110010
    not byte [data]                     ; NOT MEM16
    mov bh, byte [data]

    dump_state

    mov bx, 0

    ; test various addressing modes, 16-bit
    mov bx, 0b_01010101_11001100
    not bx                              ; NOT REG16

    mov word [data], 0b_11001100_01010101
    not word [data]                     ; NOT MEM16
    mov cx, word [data]

    dump_state
