cpu 8086
org 0xf0000

text_seg equ 0xf000

cga_seg equ 0xb800
cga_alias_seg equ 0xbc00

; startup and initialization
section .text start=(text_seg << 4)
init:
    mov ax, cga_seg
    mov ds, ax

    mov ax, cga_alias_seg
    mov es, ax

    ; read and write CGA memory
    mov byte [ds:0x11], 0x21
    mov al, byte [es:0x11]
    mov ah, 0x43

    mov word [es:0x6f], ax
    mov bx, word [ds:0x6f]

    mov word [ds:0x3ffe], bx

    ; set CGA mode
    mov al, 0b000000
    mov dx, 0x3d8
    out dx, al

    mov al, 0b101001    ; text mode, 80 column, enable output, blink
    mov dx, 0x3d8
    out dx, al

    mov al, 0b001110    ; graphics mode, 320x200, enable output, palette 2
    mov dx, 0x3d8
    out dx, al

    ; shutdown
    mov al, 0x24
    out 0x42, al

; the CPU starts here at ffff:0000
section boot start=0xffff0
    jmp text_seg:init
