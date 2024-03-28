; TODO force NASM to generate also the other variants for MOV REG8/REG8, REG8/REG16 (src/dst)
; TODO x test wrap around (register near 0xfffff + displacement, also negative displacement, also around 0x7f)

cpu 8086
org 0x00000


section data_segment start=0x10000 nobits

    dw 23 dup (?)
test_ds:
    dw  ?


section stack_segment start=0x20000 nobits

    dw 17 dup (?)
test_ss:
    dw  ?


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; set up for testing MOD R/M
    mov ax, 0x1000
    mov ds, ax
    mov ax, 0x2000
    mov ss, ax

    mov bx, 5
    mov bp, 7
    mov si, 11
    mov di, 13

%include "mem_reg_16.inc"
    out 0x80, al
%include "reg_mem_16.inc"
    out 0x81, al
%include "mem_reg_8.inc"
    out 0x82, al
%include "reg_mem_8.inc"
    out 0x83, al
%include "mem_reg_0.inc"
    out 0x84, al
%include "reg_mem_0.inc"
    out 0x85, al

    hlt


section boot start=0xffff0              ; boot
    jmp 0xd000:0x0000
