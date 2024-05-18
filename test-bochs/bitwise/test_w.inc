    ; TEST does not update registers, so we check parity instead

    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 16-bit
    mov ax, 0b_01010101_11001101
    clearf
    test ax, 0b_11001100_01010101       ; TEST AX, IMMED16
    pushf

    mov bx, 0b_01010101_11001101
    mov cx, 0b_11001100_01010101
    clearf
    test bx, cx                         ; TEST REG16, REG16
    pushf

    mov cx, 0b_01010101_11001101
    mov word [data], 0b_11001100_01010101
    clearf
    test word [data], cx                ; TEST MEM16, REG16
    pushf

    mov dx, 0b_01010101_11001101
    mov word [data], 0b_11001100_01010101
    clearf
    test dx, word [data]                ; TEST REG16, MEM16
    pushf

    dump_state

    ; test flags, 16-bit

    ; SF = 1
    mov ax, 0b_11010101_11001101
    clearf
    test ax, 0b_11001100_01010101
    dump_state

    ; ZF = 1
    mov ax, 0b_01010101_11001100
    clearf
    test ax, 0b_10101010_00110011
    dump_state

    ; PF = 1
    mov ax, 0b_01010101_11001101
    clearf
    test ax, 0b_01001100_01001101
    dump_state

    ; test TEST REG16/MEM16, IMMED16
    mov bx, 0b_01010101_11001101
    clearf
    test bx, 0b_11001100_01010101                   ; TEST REG16, IMMED16
    pushf

    mov word [data], 0b_01010101_11001101
    clearf
    test word [data], 0b_11001100_01010101          ; TEST MEM16, IMMED16
    pushf

    mov bp, data
    mov word [data], 0b_01010101_11001101
    clearf
    test word [ds:bp], 0b_11001100_01010101         ; TEST MEM16, IMMED16
    pushf

    dump_state
