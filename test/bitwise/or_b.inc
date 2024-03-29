    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 8-bit
    mov al, 0b_01010101
    or  al, 0b_11001100                 ; OR AL, IMMED8

    mov ah, 0b_01010101
    mov bl, 0b_11001100
    or  ah, bl                          ; OR REG8, REG8

    mov bl, 0b_01010101
    mov byte [data], 0b_11001100
    or  byte [data], bl                 ; OR MEM8, REG8
    mov bl, byte [data]

    mov bh, 0b_01010101
    mov byte [data], 0b_11001100
    or  bh, byte [data]                 ; OR REG8, MEM8

    dump_state

    ; test flags, 8-bit

    ; SF = 1
    mov al, 0b_01010101
    clearf
    or  al, 0b_11001100
    dump_state

    ; ZF = 1
    mov al, 0b_00000000
    clearf
    or  al, 0b_00000000
    dump_state

    ; PF = 1
    mov al, 0b_01010101
    clearf
    or  al, 0b_01001101
    dump_state

    ; test OR REG8/MEM8, IMMED8
    ; there are two opcodes, 0x80 and 0x82, with the same behavior and implementation
    mov bl, 0b_01010101
    or  bl, 0b_11001100                 ; OR REG8, IMMED8

    mov byte [data], 0b_11001100
    or  byte [data], 0b_01010101        ; OR MEM8, IMMED8
    mov bh, byte [data]

    mov bp, data
    mov byte [data], 0b_11001100
    or  byte [ds:bp], 0b_01010101       ; OR MEM8, IMMED8
    mov cl, byte [data]

    dump_state
