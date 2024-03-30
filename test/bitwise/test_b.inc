    ; TEST does not update registers, so we check parity instead

    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 8-bit
    mov al, 0b_01010101
    clearf
    test al, 0b_11001101                ; TEST AL, IMMED8
    pushf

    mov ah, 0b_01010101
    mov bl, 0b_11001101
    clearf
    test ah, bl                         ; TEST REG8, REG8
    pushf

    mov bl, 0b_01010101
    mov byte [data], 0b_11001101
    clearf
    test byte [data], bl                ; TEST MEM8, REG8
    pushf

    mov bh, 0b_01010101
    mov byte [data], 0b_11001101
    clearf
    test bh, byte [data]                ; TEST REG8, MEM8
    pushf

    dump_state

    ; test flags, 8-bit

    ; SF = 1
    mov al, 0b_11010101
    clearf
    test al, 0b_11001100
    dump_state

    ; ZF = 1
    mov al, 0b_01010101
    clearf
    test al, 0b_10101010
    dump_state

    ; PF = 1
    mov al, 0b_01010101
    clearf
    test al, 0b_01001100
    dump_state

    ; test TEST REG8/MEM8, IMMED8
    mov bl, 0b_01010101
    clearf
    test bl, 0b_11001101                ; TEST REG8, IMMED8
    pushf

    mov byte [data], 0b_11001101
    clearf
    test byte [data], 0b_01010101       ; TEST MEM8, IMMED8
    pushf

    mov bp, data
    mov byte [data], 0b_11001101
    clearf
    test byte [ds:bp], 0b_01010101      ; TEST MEM8, IMMED8
    pushf

    dump_state
