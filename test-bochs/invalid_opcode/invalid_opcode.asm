%include "common.inc"


section .text
    db  0x60                            ; invalid opcode
    call power_off
