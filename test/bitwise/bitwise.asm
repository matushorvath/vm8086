; TODO x test OR
; 0x08 OR REG8/MEM8, REG8
; 0x09 OR REG16/MEM16, REG16
; 0x0a OR REG8, REG8/MEM8
; 0x0b OR REG16, REG16/MEM16
; 0x0c OR AL, IMMED8
; 0x0d OR AX, IMMED16
; 0x80+0b001 OR REG8/MEM8, IMMED8
; 0x81+0b001 OR REG16/MEM16, IMMED16

; TODO x test TEST
; 0x84 TEST REG8/MEM8, REG8
; 0x85 TEST REG16/MEM16, REG16
; 0xa8 TEST AL, IMMED8
; 0xa9 TEST AX, IMMED16
; - 0xf6+0b000 TEST REG/MEM, IMMED b
; - 0xf7+0b000 TEST REG/MEM, IMMED w

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .data start=0x10000

    dw  7 dup 0x0000

data:
    dw  0


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    mov dx, 0x1000
    mov ds, dx

    out 0x42, al

%macro clearf 0
    mov dx, 0
    push dx
    popf
%endmacro

    out 0x80, al

%include "and_b.inc"
%include "and_w.inc"

;    out 0x81, al

;%include "or_b.inc"
;%include "or_w.inc"

    out 0x82, al

%include "xor_b.inc"
%include "xor_w.inc"

    hlt


section boot start=0xffff0              ; boot
    int3
