; TODO check other instructions than MOV; make sure all instruction variants that access memory are handled

%include "common.inc"


%macro clear_registers 0
    mov ax, 0
    mov bx, 0
    mov cx, 0
    mov dx, 0
    mov bp, 0
    mov sp, 0
    mov si, 0
    mov di, 0
%endmacro


ds_seg      equ 0x2000
ss_seg      equ 0x3000
es_seg      equ 0x4000


section .text
    jmp start

    ; make sure the data_read starts at an interesting address, not 0
    dw  17 dup 0x0000

data_read:
    dw  0x1111

    ; we can't write to .text since it's in ROM, but we can write to other segments
data_write:
    dw  0x0000

start:
    dump_state
    mark 0x80

    ; some basic tests
    ; TODO HW lock freezes on bochs, investigate
    lock nop
    repz nop
    repnz nop

    ; set up ds
    mov dx, ds_seg
    mov ds, dx

    ; check segment prefix with a segment register
    mov es, [cs:data_read]
    mov [ds:data_write], es

    ; make the value visible in dump without depending on segment prefixes
    mov dx, [data_write]

    dump_state
    mark 0x81

    ; set up other segments
    mov ax, ss_seg
    mov ss, ax
    mov ax, es_seg
    mov es, ax

    ; set up different data in each segment
    mov word [ds:data_read], 0x2222
    mov word [ss:data_read], 0x3333
    mov word [es:data_read], 0x4444

    dump_state
    mark 0x82

    ; check segment prefixes when using just displacement
    clear_registers
    mov cx, [data_read]
    mov dx, [cs:data_read]
    mov sp, [ds:data_read]
    mov si, [ss:data_read]
    mov di, [es:data_read]

    dump_state
    mark 0x83

    ; check segment prefixes when using bx
    clear_registers
    mov bx, data_read
    mov cx, [bx]
    mov dx, [cs:bx]
    mov sp, [ds:bx]
    mov si, [ss:bx]
    mov di, [es:bx]

    dump_state
    mark 0x84

    ; check segment prefixes when using bp
    clear_registers
    mov bp, data_read
    mov cx, [bp]
    mov dx, [cs:bp]
    mov sp, [ds:bp]
    mov si, [ss:bp]
    mov di, [es:bp]

    dump_state
    mark 0x85

    ; check the other direction

    ; check segment prefixes when using bp
    clear_registers
    mov bx, data_write
    mov bp, data_write

    mov ax, 0x3456
    mov [ds:bp], ax
    mov ax, 0x4567
    mov [ss:bx], ax
    mov ax, 0x5678
    mov [es:data_write], ax

    clear_registers
    mov bx, [ds:data_write]
    mov cx, [ss:data_write]
    mov dx, [es:data_write]

    dump_state
    mark 0x86

    ; check that segment prefixes get used up after one instruction
    clear_registers
    mov bx, [es:data_read]
    mov cx, [data_read]

    mov dx, [es:data_read]
    mov si, [ss:data_read]
    mov di, [data_read]

    dump_state
    mark 0x87

    ; check that combinations of prefixes work correctly
    clear_registers

    ; TODO HW rep lock freezes on bochs, investigate
    lock mov bx, [es:data_read]
    mov cx, [data_read]

    rep mov dx, [es:data_read]
    mov sp, [data_read]

    ; TODO HW rep lock mov freezes on bochs, investigate
    rep lock mov si, [es:data_read]
    mov di, [data_read]

    dump_state
    mark 0x88

    ; check segment prefix with MOV AX
    clear_registers
    mov ax, [data_read]
    mov [data_write], ax
    mov dx, [data_write]                ; make the value visible in dump

    dump_state
    mark 0x89

    clear_registers
    mov ax, [es:data_read]
    mov [es:data_write], ax
    mov dx, [es:data_write]             ; make the value visible in dump

    dump_state
    mark 0x8a

    ; check segment prefix with MOV MEM8, IMMED8
    clear_registers
    mov bp, data_write

    mov [bp], byte 0x13
    mov [ds:bp], byte 0x24

    mov al, [bp]                        ; make the values visible in dump
    mov bl, [ds:bp]

    dump_state
    mark 0x8b

    ; check segment prefix with MOV MEM16, IMMED16
    clear_registers
    mov bp, data_write

    mov [bp], word 0x1357
    mov [ds:bp], word 0x2468

    mov ax, [bp]                        ; make the values visible in dump
    mov bx, [ds:bp]

    dump_state
    mark 0x8c

    call power_off
