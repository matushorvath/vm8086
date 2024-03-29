; TODO x test carry out of low byte (inc/dec)
; TODO x test carry out of high byte (inc/dec)
; TODO x test flag_zero
; TODO x test flag_parity is calculated only from low byte
; TODO x test flag_auxiliary_carry for low nibble
; TODO x test flag_overflow when moving 0x7f->0x80 and back

%include "common.inc"


section .data start=0xe0000

    dw  13 dup 0x0000
data:
    dw  0


section .text
    dump_state

    ; these tests break sp
%include "inc_reg16.inc"
%include "dec_reg16.inc"
%include "inc_reg8.inc"
%include "dec_reg8.inc"

%include "inc_dec_mem.inc"

    hlt
