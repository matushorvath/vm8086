%include "common.inc"


src_seg             equ extra_addr / 0x10
src_addr            equ src_seg * 0x10

section src_segment start=src_addr
    resw 17
src_data:
    %assign i 1
    %rep 32
        db  i
        %assign i i + 1
    %endrep


dst_seg             equ 0x1000
dst_addr            equ dst_seg * 0x10

section dst_segment start=dst_addr nobits
    resw 23
dst_data:
    resw 0x100


section .text
    dump_state

    ; set up segments
    mov ax, src_seg
    mov ds, ax
    mov ax, dst_seg
    mov es, ax

    ; make destination data visible in dump_state by setting up stack at that location
    mov ss, ax
    mov sp, dst_data - 0xf

    dump_state

%include "movs_b.inc"

    call power_off
