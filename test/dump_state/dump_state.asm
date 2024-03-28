cpu 8086
org 0xd0000


section .text start=0xffff0              ; boot
    out 0x42, al
    hlt
