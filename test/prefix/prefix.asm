; TODO check other instructions than MOV; make sure all instruction variants that access memory are handled

cpu 8086
org 0x00000


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


section .text start=0xd0000
    jmp start

    ; make sure the data_read starts at an interesting address, not 0
    dw  17 dup 0x0000
data_read:
    dw  0x1111
data_write:
    dw  0x0000

start:
    out 0x42, al
    out 0x80, al

    ; some basic tests
    lock nop
    repz nop
    repnz nop

    ; check segment prefix with a segment register
    mov es, [cs:data_read]
    mov [cs:data_write], es

    ; make the value visible in dump without depending on segment prefixes
    mov dx, cs
    mov ds, dx
    mov dx, [data_write]

    out 0x42, al
    out 0x81, al

    ; set up segments (cs is already set up by jmp)
    mov ax, 0x2000
    mov ds, ax
    mov ax, 0x3000
    mov ss, ax
    mov ax, 0x4000
    mov es, ax

    ; set up different data in each segment
    mov word [ds:data_read], 0x2222
    mov word [ss:data_read], 0x3333
    mov word [es:data_read], 0x4444

    out 0x42, al
    out 0x82, al

    ; check segment prefixes when using just displacement
    clear_registers
    mov cx, [data_read]
    mov dx, [cs:data_read]
    mov sp, [ds:data_read]
    mov si, [ss:data_read]
    mov di, [es:data_read]

    out 0x42, al
    out 0x83, al

    ; check segment prefixes when using bx
    clear_registers
    mov bx, data_read
    mov cx, [bx]
    mov dx, [cs:bx]
    mov sp, [ds:bx]
    mov si, [ss:bx]
    mov di, [es:bx]

    out 0x42, al
    out 0x84, al

    ; check segment prefixes when using bp
    clear_registers
    mov bp, data_read
    mov cx, [bp]
    mov dx, [cs:bp]
    mov sp, [ds:bp]
    mov si, [ss:bp]
    mov di, [es:bp]

    out 0x42, al
    out 0x85, al

    ; check the other direction

    ; check segment prefixes when using bp
    clear_registers
    mov bx, data_write
    mov bp, data_write

    mov ax, 0x2345
    mov [cs:bp], ax
    mov ax, 0x3456
    mov [ds:bp], ax
    mov ax, 0x4567
    mov [ss:bx], ax
    mov ax, 0x5678
    mov [es:data_write], ax

    clear_registers
    mov ax, [cs:data_write]             ; make the values visible in dump
    mov bx, [ds:data_write]
    mov cx, [ss:data_write]
    mov dx, [es:data_write]

    out 0x42, al
    out 0x86, al

    ; check that segment prefixes get used up after one instruction
    clear_registers
    mov bx, [es:data_read]
    mov cx, [data_read]

    mov dx, [es:data_read]
    mov si, [ss:data_read]
    mov di, [data_read]

    out 0x42, al
    out 0x87, al

    ; check that combinations of prefixes work correctly
    clear_registers

    lock mov bx, [es:data_read]
    mov cx, [data_read]

    rep mov dx, [es:data_read]
    mov sp, [data_read]

    rep lock mov si, [es:data_read]
    mov di, [data_read]

    out 0x42, al
    out 0x88, al

    ; check segment prefix with MOV AX
    clear_registers
    mov ax, [data_read]
    mov [data_write], ax
    mov dx, [data_write]                ; make the value visible in dump

    out 0x42, al
    out 0x89, al

    clear_registers
    mov ax, [es:data_read]
    mov [es:data_write], ax
    mov dx, [es:data_write]             ; make the value visible in dump

    out 0x42, al
    out 0x8a, al

    ; check segment prefix with MOV MEM8, IMMED8
    clear_registers
    mov bp, data_write

    mov [bp], byte 0x13
    mov [ds:bp], byte 0x24
    mov [cs:bp], byte 0x35

    mov al, [bp]                        ; make the values visible in dump
    mov bl, [ds:bp]
    mov cl, [cs:bp]

    out 0x42, al
    out 0x8b, al

    ; check segment prefix with MOV MEM16, IMMED16
    clear_registers
    mov bp, data_write

    mov [bp], word 0x1357
    mov [ds:bp], word 0x2468
    mov [cs:bp], word 0x3579

    mov ax, [bp]                        ; make the values visible in dump
    mov bx, [ds:bp]
    mov cx, [cs:bp]

    out 0x42, al
    out 0x8c, al

    hlt


section boot start=0xffff0              ; boot
    jmp 0xd000:0x0000
