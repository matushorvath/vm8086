%include "common.inc"


section .text
    db  0x0f                            ; invalid opcode
    hlt
