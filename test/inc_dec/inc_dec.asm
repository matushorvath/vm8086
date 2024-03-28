; TODO x test carry out of low byte (inc/dec)
; TODO x test carry out of high byte (inc/dec)
; TODO x test flag_zero
; TODO x test flag_parity is calculated only from low byte
; TODO x test flag_auxiliary_carry for low nibble
; TODO x test flag_overflow when moving 0x7f->0x80 and back

cpu 8086


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0xd000             ; INT 3


section .data start=0x10000

data:
    dw  13 dup 0x0000
    dw  0


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; these tests break sp
%include "inc_reg16.inc"
%include "dec_reg16.inc"
%include "inc_reg8.inc"
%include "dec_reg8.inc"

%include "inc_dec_mem.inc"

    hlt


section boot start=0xffff0              ; boot
    int3
