%include "common.inc"


DS_TABLE equ 937
SS_TABLE equ 983

DS_INDEX equ 167
SS_INDEX equ 193

DS_OVERFLOW equ 17
SS_OVERFLOW equ 19

section data_segment start=0x10000 nobits
    resw 0x10000


section stack_segment start=0x20000 nobits
    resw 0x10000


section .text
    dump_state

    ; set up segments
    mov ax, 0x1000
    mov ds, ax
    mov ax, 0x2000
    mov ss, ax

    ; set up data in the tables
    mov byte [ds:DS_TABLE + DS_INDEX], 0xf1
    mov byte [ss:SS_TABLE + SS_INDEX], 0xd3

    ; test with al == 0
    mov bx, DS_TABLE + DS_INDEX
    mov al, 0
    xlat
    mov cl, al

    mov bx, SS_TABLE + SS_INDEX
    mov al, 0
    ss xlat
    mov ch, al

    ; test with al != 0
    mov bx, DS_TABLE
    mov al, DS_INDEX
    xlat
    mov dl, al

    mov bx, SS_TABLE
    mov al, SS_INDEX
    ss xlat
    mov dh, al

    dump_state

    ; test with bx towards the end of the segment
    ; and al large enough to wrap around to the start of the segment
    mov byte [ds:DS_OVERFLOW], 0x67
    mov bx, 0x10000 - DS_INDEX + DS_OVERFLOW
    mov al, DS_INDEX
    xlat
    mov cl, al

    mov byte [ss:SS_OVERFLOW], 0x71
    mov bx, 0x10000 - SS_INDEX + SS_OVERFLOW
    mov al, SS_INDEX
    ss xlat
    mov ch, al

    dump_state

    call power_off
