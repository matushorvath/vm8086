cpu 8086
org 0x00000


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0xd000             ; INT 3


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    out 0x42, al

%include "reg_reg.inc"
    out 0x80, al
%include "reg_immed.inc"
    out 0x81, al

; TODO x MOV MEM8, IMMED8
; TODO x MOV MEM16, IMMED16

; TODO x MOV AL, MEM8
; TODO x MOV AX, MEM16
; TODO x MOV MEM8, AL
; TODO x MOV MEM16, AX

    hlt


section boot start=0xffff0              ; boot
    int3


; TODO x new test for XCHG

; XCHG AX, CX
; XCHG AX, DX
; XCHG AX, BX
; XCHG AX, SP
; XCHG AX, BP
; XCHG AX, SI
; XCHG AX, DI

; XCHG REG8, REG8/MEM8
; XCHG REG16, REG16/MEM16
