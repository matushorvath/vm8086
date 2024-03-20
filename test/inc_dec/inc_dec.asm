cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0x8000             ; INT 3


section .text start=0x80000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; increment 16-bit
    inc ax

    inc bx
    inc bx

    inc cx
    inc cx
    inc cx

    inc dx
    inc dx
    inc dx
    inc dx

    inc bp
    inc bp
    inc bp
    inc bp
    inc bp

    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    inc sp
    ; yes, sp = 0 happens to be correct here

    inc si
    inc si
    inc si
    inc si
    inc si
    inc si
    inc si

    inc di
    inc di
    inc di
    inc di
    inc di
    inc di
    inc di
    inc di

    out 0x42, al

    ; decrement 16-bit
    dec di

    dec si
    dec si

    dec sp
    dec sp
    dec sp

    dec bp
    dec bp
    dec bp
    dec bp

    dec dx
    dec dx
    dec dx
    dec dx
    dec dx

    dec cx
    dec cx
    dec cx
    dec cx
    dec cx
    dec cx

    dec bx
    dec bx
    dec bx
    dec bx
    dec bx
    dec bx
    dec bx

    dec ax
    dec ax
    dec ax
    dec ax
    dec ax
    dec ax
    dec ax
    dec ax

    out 0x42, al

; TODO test carry out of low byte (inc/dec)
; TODO test carry out of high byte (inc/dec)
; TODO test flag_zero
; TODO test flag_parity is calculated only from low byte
; TODO test flag_auxiliary_carry for low nibble
; TODO test flag_overflow when moving 0x7f->0x80 and back

    ; increment 8-bit
    ; TODO 8-bit inc
;    inc al

;    inc ah
;    inc ah

;    inc bl
;    inc bl
;    inc bl

;    inc bh
;    inc bh
;    inc bh
;    inc bh

;    inc cl
;    inc cl
;    inc cl
;    inc cl
;    inc cl

;    inc ch
;    inc ch
;    inc ch
;    inc ch
;    inc ch
;    inc ch

;    inc dl
;    inc dl
;    inc dl
;    inc dl
;    inc dl
;    inc dl
;    inc dl

;    inc dh
;    inc dh
;    inc dh
;    inc dh
;    inc dh
;    inc dh
;    inc dh
;    inc dh

;    out 0x42, al

    ; decrement 8-bit
    ; TODO 8-bit dec
;    dec al
;    dec al
;    dec al
;    dec al
;    dec al
;    dec al
;    dec al
;    dec al

;    dec ah
;    dec ah
;    dec ah
;    dec ah
;    dec ah
;    dec ah
;    dec ah

;    dec bl
;    dec bl
;    dec bl
;    dec bl
;    dec bl
;    dec bl

;    dec bh
;    dec bh
;    dec bh
;    dec bh
;    dec bh

;    dec cl
;    dec cl
;    dec cl
;    dec cl

;    dec ch
;    dec ch
;    dec ch

;    dec dl
;    dec dl

;    dec dh

;    out 0x42, al

; TODO
; INC REG8/MEM8
; DEC REG8/MEM8
; INC MEM16
; DEC MEM16

    hlt


section boot start=0xffff0              ; boot
    int3
