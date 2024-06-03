; TODO test carry out of low byte (inc/dec)
; TODO test carry out of high byte (inc/dec)
; TODO test flag_zero
; TODO test flag_parity is calculated only from low byte
; TODO test flag_auxiliary_carry for low nibble
; TODO test flag_overflow when moving 0x7f->0x80 and back

%include "common.inc"


bss_seg     equ 0x8000

section .bss start=(bss_seg * 0x10)
orig_sp:
    resw 1

    resw 12

data:
    resw 1


section .data start=data_addr


section .text
    dump_state

    ; these tests break sp
    mark 0x80
%include "inc_reg16.inc"
    mark 0x81
%include "dec_reg16.inc"
    mark 0x82
%include "inc_reg8.inc"
    mark 0x83
%include "dec_reg8.inc"

    mark 0x84
%include "inc_dec_mem.inc"
    mark 0x85

    call power_off
