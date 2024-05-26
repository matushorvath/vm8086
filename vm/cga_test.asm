cpu 8086
org 0xf0000

text_seg equ 0xf000

; startup and initialization
section .text start=(text_seg << 4)
init:
    mov al, 0x24
    out 0x42, al

; the CPU starts here at ffff:0000
section boot start=0xffff0
    jmp text_seg:init
