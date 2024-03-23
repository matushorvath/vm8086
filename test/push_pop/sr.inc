    ; push segment registers
    mov ax, 0x1234
    mov ds, ax
    mov ax, 0x5678
    mov ss, ax                          ; this moves the stack
    mov ax, 0x9abc
    mov es, ax

    push cs
    push ds
    push ss
    push es

    out 0x42, al

    ; pop segment registers intentionally in different order, ss last
    pop ds
    pop es
    pop ss

    out 0x42, al
