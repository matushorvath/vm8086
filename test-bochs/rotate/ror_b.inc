    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov si, 0
    mov di, 0
    mov bp, 0

    ; rotate by various amounts
    mov ah, 0b_01001101
    clearf
    ror ah, 1
    pushf

    mov al, 0b_01001101
    mov cl, 0
    clearf
    ror al, cl
    pushf

    mov bh, 0b_01001101
    mov cl, 1
    clearf
    ror bh, cl
    pushf

    mov bl, 0b_01001101
    mov cl, 2
    clearf
    ror bl, cl
    pushf

    mov ch, 0b_01001101
    mov cl, 3
    clearf
    ror ch, cl
    pushf

    mov dh, 0b_01001101
    mov cl, 4
    clearf
    ror dh, cl
    pushf

    mov dl, 0b_01001101
    mov cl, 5
    clearf
    ror dl, cl
    pushf

    dump_state

    mov ah, 0b_01001101
    mov cl, 6
    clearf
    ror ah, cl
    pushf

    mov al, 0b_01001101
    mov cl, 7
    clearf
    ror al, cl
    pushf

    mov bh, 0b_01001101
    mov cl, 8
    clearf
    ror bh, cl
    pushf

    mov bl, 0b_01001101
    mov cl, 9
    clearf
    ror bl, cl
    pushf

    mov ch, 0b_01001101
    mov cl, 10
    clearf
    ror ch, cl
    pushf

    mov dh, 0b_01001101
    mov cl, 0x7f
    clearf
    ror dh, cl
    pushf

    mov dl, 0b_01001101
    mov cl, 0xff
    clearf
    ror dl, cl
    pushf

    dump_state

    ; test various addressing modes, 8-bit
    mov byte [data], 0b_01001101
    clearf
    ror byte [data], 1
    mov ah, [data]

    mov bp, data
    mov byte [bp], 0b_01001101
    clearf
    ror byte [bp], 1
    mov al, [bp]

    dump_state
