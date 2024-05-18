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
