%include "common.inc"


section .text
    dump_state

%include "reg_reg.inc"
    mark 0x80
%include "reg_immed.inc"
    mark 0x81

; TODO x MOV MEM8, IMMED8
; TODO x MOV MEM16, IMMED16

; TODO x MOV AL, MEM8
; TODO x MOV AX, MEM16
; TODO x MOV MEM8, AL
; TODO x MOV MEM16, AX

    call power_off

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
