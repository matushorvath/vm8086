; TODO <immed> REG8/MEM8, IMMED8

    ; test various addressing modes, 8-bit
    mov al, 01010101b
    xor al, 11001100b                   ; XOR AL, IMMED8

    mov ah, 01010101b
    mov bl, 11001100b
    xor ah, bl                          ; XOR REG8, REG8

    mov bl, 01010101b
    mov byte [data], 11001100b
    xor byte [data], bl                 ; XOR MEM8, REG8
    mov bl, byte [data]

    mov bh, 01010101b
    mov byte [data], 11001100b
    xor bh, byte [data]                 ; XOR REG8, MEM8

    out 0x42, al

    ; test flags, 8-bit

    ; SF = 1
    mov al, 01010101b
    clearf
    xor al, 11001100b
    out 0x42, al

    ; ZF = 1
    mov al, 01010101b
    clearf
    xor al, 01010101b
    out 0x42, al

    ; PF = 1
    mov al, 01010101b
    clearf
    xor al, 01001100b
    out 0x42, al
