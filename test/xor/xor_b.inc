    ; test various addressing modes, 8-bit
    mov al, 0b_01010101
    xor al, 0b_11001100                 ; XOR AL, IMMED8

    mov ah, 0b_01010101
    mov bl, 0b_11001100
    xor ah, bl                          ; XOR REG8, REG8

    mov bl, 0b_01010101
    mov byte [data], 0b_11001100
    xor byte [data], bl                 ; XOR MEM8, REG8
    mov bl, byte [data]

    mov bh, 0b_01010101
    mov byte [data], 0b_11001100
    xor bh, byte [data]                 ; XOR REG8, MEM8

    out 0x42, al

    ; test flags, 8-bit

    ; SF = 1
    mov al, 0b_01010101
    clearf
    xor al, 0b_11001100
    out 0x42, al

    ; ZF = 1
    mov al, 0b_01010101
    clearf
    xor al, 0b_01010101
    out 0x42, al

    ; PF = 1
    mov al, 0b_01010101
    clearf
    xor al, 0b_01001100
    out 0x42, al

    ; test XOR REG8/MEM8, IMMED8
    ; there are two opcodes, 0x80 and 0x82, with the same behavior and implementation
    mov bl, 0b_01010101
    xor bl, 0b_11001100                 ; XOR REG8, IMMED8

    mov byte [data], 0b_11001100
    xor byte [data], 0b_01010101        ; XOR MEM8, IMMED8
    mov bh, byte [data]

    mov bp, data
    mov byte [data], 0b_11001100
    xor byte [ds:bp], 0b_01010101       ; XOR MEM8, IMMED8
    mov cl, byte [data]

    out 0x42, al
