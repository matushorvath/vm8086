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

%include "reg_reg.inc"
    out 0x80, al
%include "reg_immed.inc"
    out 0x81, al

    ; set up for testing MOD RM
    mov ax, 0x1000
    mov ds, ax
    mov ax, 0x2000
    mov ss, ax

    mov bx, 5
    mov bp, 7
    mov si, 11
    mov di, 13

%include "mem8_reg8_16.inc"
    out 0x82, al
%include "reg8_mem8_16.inc"
    out 0x83, al
%include "mem8_reg8_8.inc"
    out 0x84, al
%include "reg8_mem8_8.inc"
    out 0x85, al
%include "mem8_reg8_0.inc"
    out 0x86, al
%include "reg8_mem8_0.inc"
    out 0x87, al

; TODO test MOD REG RM with 16-bit registers
; TODO force NASM to generate also the other variants for MOV REG8/REG8, REG8/REG16 (src/dst)

; TODO MOV MEM8, REG8
; TODO MOV MEM16, REG16
; TODO MOV REG8, MEM8
; TODO MOV REG16, MEM16

; TODO MOV MEM8, IMMED8
; TODO MOV MEM16, IMMED16

; TODO MOV AL, MEM8
; TODO MOV AX, MEM16
; TODO MOV MEM8, AL
; TODO MOV MEM16, AX

    hlt


section boot start=0xffff0              ; boot
    int3


; TODO new test for XCHG

; XCHG AX, CX
; XCHG AX, DX
; XCHG AX, BX
; XCHG AX, SP
; XCHG AX, BP
; XCHG AX, SI
; XCHG AX, DI

; XCHG REG8, REG8/MEM8
; XCHG REG16, REG16/MEM16
