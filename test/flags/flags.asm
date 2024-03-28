cpu 8086
org 0x00000


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0xd000             ; INT 3


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    ; reset all flags
    mov dx, 0
    push dx
    popf
    out 0x42, al

%macro set_reset_instruction 2
    ; set flag and push
    %1
    pushf
    out 0x42, al

    ; reset all flags
    mov dx, 0
    push dx
    popf

    ; pop flags
    popf
    out 0x42, al

    ; clear flag and push
    %2
    pushf
    out 0x42, al

    ; set all flags
    mov dx, 0xffff
    push dx
    popf

    ; pop flags
    popf
    out 0x42, al
%endmacro

    out 0x80, al

    ; set/reset individual flags with dedicated instructions
    set_reset_instruction stc, clc
    set_reset_instruction sti, cli
    set_reset_instruction std, cld
    set_reset_instruction cmc, cmc

%macro set_reset_stack 1
    ; load ax with current status
    pushf
    pop ax

    ; set flag and push
    xor ax, word %1
    push ax
    popf
    pushf
    out 0x42, al

    ; reset all flags
    mov dx, 0
    push dx
    popf

    ; pop flags
    popf
    out 0x42, al

    ; clear flag and push
    xor ax, word %1
    push ax
    popf
    pushf
    out 0x42, al

    ; set all flags
    mov dx, 0xffff
    push dx
    popf

    ; pop flags
    popf
    out 0x42, al
%endmacro

    out 0x81, al

    ; set/reset individual flags with popf
    set_reset_stack 0b_0000000000000001
    set_reset_stack 0b_0000000000000100
    set_reset_stack 0b_0000000000010000
    set_reset_stack 0b_0000000001000000
    set_reset_stack 0b_0000000010000000

    set_reset_stack 0b_0000000100000000
    set_reset_stack 0b_0000001000000000
    set_reset_stack 0b_0000010000000000
    set_reset_stack 0b_0000100000000000

%macro set_reset_ah 1
    ; load ah with current status
    pushf
    pop ax
    mov ah, al

    ; set flag and store to ah
    xor ah, byte %1
    sahf
    mov ah, 0
    lahf
    out 0x42, al

    ; clear flag and store to ah
    xor ah, byte %1
    sahf
    mov ah, 0
    lahf
    out 0x42, al

%endmacro

    out 0x82, al

    ; set/reset individual flags with sahf
    set_reset_ah 0b_00000001
    set_reset_ah 0b_00000100
    set_reset_ah 0b_00010000
    set_reset_ah 0b_01000000
    set_reset_ah 0b_10000000

    hlt


section boot start=0xffff0              ; boot
    int3
