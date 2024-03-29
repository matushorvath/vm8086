    ; clear registers
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0

    ; test various addressing modes, 16-bit
    mov ax, 0b_01010101_11001100
    or  ax, 0b_11001100_01010101        ; OR AX, IMMED16

    mov bx, 0b_01010101_11001100
    mov cx, 0b_11001100_01010101
    or  bx, cx                          ; OR REG16, REG16

    mov cx, 0b_01010101_11001100
    mov word [data], 0b_11001100_01010101
    or  word [data], cx                 ; OR MEM16, REG16
    mov cx, word [data]

    mov dx, 0b_01010101_11001100
    mov word [data], 0b_11001100_01010101
    or  dx, word [data]                 ; OR REG16, MEM16

    dump_state

    ; test flags, 16-bit

    ; SF = 1
    mov ax, 0b_01010101_11001100
    clearf
    or  ax, 0b_11001100_01010101
    dump_state

    ; ZF = 1
    mov ax, 0b_00000000_00000000
    clearf
    or  ax, 0b_00000000_00000000
    dump_state

    ; PF = 1
    mov ax, 0b_01010101_11001101
    clearf
    or  ax, 0b_01001100_01001100
    dump_state

    ; test OR REG16/MEM16, IMMED16
    mov bx, 0b_01010101_11001100
    or  bx, 0b_11001100_01010101                    ; OR REG16, IMMED16

    mov word [data], 0b_01010101_11001100
    or  word [data], 0b_11001100_01010101           ; OR MEM16, IMMED16
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_01010101_11001100
    or  word [ds:bp], 0b_11001100_01010101          ; OR MEM16, IMMED16
    mov dx, word [data]

    dump_state

    ; test OR REG16/MEM16, IMMED8, positive value
    mov bx, 0b_01010101_11001100
    or  bx, 0b_01010101                             ; OR REG16, IMMED8

    mov word [data], 0b_01010101_11001100
    or  word [data], 0b_01010101                    ; OR MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_01010101_11001100
    or  word [ds:bp], 0b_01010101                   ; OR MEM16, IMMED8
    mov dx, word [data]

    dump_state

    ; test OR REG16/MEM16, IMMED8, negative value
    mov bx, 0b_11001100_01010101
    or  bx, 0b_11111111_11001100                    ; OR REG16, IMMED8

    mov word [data], 0b_11001100_01010101
    or  word [data], 0b_11111111_11001100           ; OR MEM16, IMMED8
    mov cx, word [data]

    mov bp, data
    mov word [data], 0b_11001100_01010101
    or  word [ds:bp], 0b_11111111_11001100          ; OR MEM16, IMMED8
    mov dx, word [data]

    dump_state
