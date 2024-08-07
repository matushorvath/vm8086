%include "common.inc"


src_data_count      equ 64

src_seg             equ extra_addr / 0x10
src_addr            equ src_seg * 0x10

section src_segment start=src_addr
    dw  17 dup (0x0000)
src_data:
    %assign i 1
    %rep src_data_count
        db  i
        %assign i i + 1
    %endrep

    db  src_data_count dup (0xff)

value_ab_b:
    db  src_data_count dup (0xab)
value_ab_b_end:
    db 0xcd

value_cdef_w:
    dw  src_data_count dup (0xcdef)
value_cdef_w_end:
    dw 0xcdab

    dw  src_data_count dup (0xff)


dst_seg             equ 0x1000
dst_addr            equ dst_seg * 0x10

section dst_segment start=dst_addr nobits
    resw 23
dst_data:
    resw 0x100


%macro clear_dst 0
    %assign i 0
    %rep src_data_count
        mov byte [es:i], 0x00
        %assign i i + 1
    %endrep
%endmacro


section .text
    dump_state

    ; set up segments
    mov ax, src_seg
    mov ds, ax
    mov ax, dst_seg
    mov es, ax

    ; make destination data visible in dump_state by setting up stack at that location
    mov ss, ax
    mov sp, dst_data

    dump_state

; TODO test all the wraparounds: SI/DI (16-bit), src/dst physical address (20-bit)

%include "movs_b.inc"
clear_dst
%include "movs_w.inc"
clear_dst

%include "cmps_b.inc"
clear_dst
%include "cmps_w.inc"
clear_dst

%include "scas_b.inc"
clear_dst
%include "scas_w.inc"
clear_dst

%include "lods_b.inc"
clear_dst
%include "lods_w.inc"
clear_dst

%include "stos_b.inc"
clear_dst
%include "stos_w.inc"
clear_dst

    call power_off
