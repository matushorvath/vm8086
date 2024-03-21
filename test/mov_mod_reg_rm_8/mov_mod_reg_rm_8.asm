; TODO force NASM to generate also the other variants for MOV REG8/REG8, REG8/REG16 (src/dst)
; TODO test MOD REG RM with 16-bit registers

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section data_segment start=0x10000

    dw 23 dup (0x0000)
test_ds:
    dw  0


section stack_segment start=0x20000

    dw 17 dup (0x0000)
test_ss:
    dw  0


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; set up for testing MOD RM
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
    int3
