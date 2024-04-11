    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; shift by various amounts
    mov ah, 0b_01001101
    clearf
    sar ah, 1
    pushf

    mov al, 0b_01001101
    mov cl, 0
    clearf
    sar al, cl
    pushf

    mov bh, 0b_01001101
    mov cl, 1
    clearf
    sar bh, cl
    pushf

    mov bl, 0b_01001101
    mov cl, 2
    clearf
    sar bl, cl
    pushf

    mov ch, 0b_01001101
    mov cl, 3
    clearf
    sar ch, cl
    pushf

    mov dh, 0b_01001101
    mov cl, 4
    clearf
    sar dh, cl
    pushf

    mov dl, 0b_01001101
    mov cl, 5
    clearf
    sar dl, cl
    pushf

    dump_state

    mov ah, 0b_01001101
    mov cl, 6
    clearf
    sar ah, cl
    pushf

    mov al, 0b_01001101
    mov cl, 7
    clearf
    sar al, cl
    pushf

    mov bh, 0b_01001101
    mov cl, 8
    clearf
    sar bh, cl
    pushf

    mov bl, 0b_01001101
    mov cl, 9
    clearf
    sar bl, cl
    pushf

    mov ch, 0b_01001101
    mov cl, 10
    clearf
    sar ch, cl
    pushf

    mov dh, 0b_01001101
    mov cl, 0x7f
    clearf
    sar dh, cl
    pushf

    mov dl, 0b_01001101
    mov cl, 0xff
    clearf
    sar dl, cl
    pushf

    dump_state

    ; test various addressing modes, 8-bit
    mov byte [data], 0b_01001101
    clearf
    sar byte [data], 1
    mov ah, [data]

    mov bp, data
    mov byte [bp], 0b_01001101
    clearf
    sar byte [bp], 1
    mov al, [bp]

    dump_state
