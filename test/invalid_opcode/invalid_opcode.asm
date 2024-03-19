cpu 8086

org 0x00000


section .text start=0xffff0             ; boot
    db  0x0f                            ; invalid opcode
    hlt
