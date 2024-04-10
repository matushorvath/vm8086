    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; shift by various amounts
    mov ah, 0b_10110010
    clearf
    shl ah, 1
    pushf

    mov al, 0b_10110010
    mov cl, 0
    clearf
    shl al, cl
    pushf

    mov bh, 0b_10110010
    mov cl, 1
    clearf
    shl bh, cl
    pushf

    mov bl, 0b_10110010
    mov cl, 2
    clearf
    shl bl, cl
    pushf

    mov ch, 0b_10110010
    mov cl, 3
    clearf
    shl ch, cl
    pushf

    mov dh, 0b_10110010
    mov cl, 4
    clearf
    shl dh, cl
    pushf

    mov dl, 0b_10110010
    mov cl, 5
    clearf
    shl dl, cl
    pushf

    dump_state

    mov ah, 0b_10110010
    mov cl, 6
    clearf
    shl ah, cl
    pushf

    mov al, 0b_10110010
    mov cl, 7
    clearf
    shl al, cl
    pushf

    mov bh, 0b_10110010
    mov cl, 8
    clearf
    shl bh, cl
    pushf

    mov bl, 0b_10110010
    mov cl, 9
    clearf
    shl bl, cl
    pushf

    mov ch, 0b_10110010
    mov cl, 10
    clearf
    shl ch, cl
    pushf

    mov dh, 0b_10110010
    mov cl, 0x7f
    clearf
    shl dh, cl
    pushf

    mov dl, 0b_10110010
    mov cl, 0xff
    clearf
    shl dl, cl
    pushf

    dump_state

    ; test various addressing modes, 8-bit
    mov byte [data], 0b_10110010
    clearf
    shl byte [data], 1
    mov ah, [data]

    mov bp, data
    mov byte [bp], 0b_10110010
    clearf
    shl byte [bp], 1
    mov al, [bp]

    dump_state
