%ifndef BOCHS
%ifndef VM8086
    %error "Neither BOCHS nor VM8086 was defined."
%endif
%endif


; bochs allows option roms between c8000 and dfffff, vgabios.bin ends at c9600
; we use ca000 for the header and cb000 for the extra segment
extra_seg   equ 0xc000
extra_addr  equ 0xcb000
extra_size  equ 0x5000

text_seg    equ 0xd000
text_addr   equ 0xd0000
text_size   equ 0x8000

util_addr   equ 0xd8000
util_size   equ 0x4000

data_addr   equ 0xdc000
data_size   equ 0x4000

rom_addr    equ 0xca000
rom_size    equ 0x16000


cpu 8086
org rom_addr


; option rom signature, needed for booting in bochs
; TODO remove this for vm8086, just do a db X instead
section header start=rom_addr
    dw  0xaa55                                              ; signature
    db  rom_size / 0x200                                    ; size in 512 byte blocks
    jmp text_seg:init


; startup and initialization
section .text start=text_addr
    ; TODO remove these three bytes (and fix all tests)
    db  3 dup (0)
init:
    call initialize


%ifdef BOCHS
section image_end start=(rom_addr + rom_size - 1)
    ; dummy section to make sure the image is exactly rom_size bytes long
    db  0
%endif


%ifdef VM8086
boot_addr   equ 0xffff0

section boot start=boot_addr
    ; the CPU starts here at ffff:0000
    jmp text_seg:init

    ; to have a round file size, fill the image up to 0x100000
    db  (0x100000 - boot_addr) - ($ - $$) dup 0
%endif


; utilities

section util start=util_addr

initialize:
%ifdef BOCHS
    ; initialize COM1
    mov ah, 0x00                                            ; init serial port
    mov dx, 0                                               ; COM1
    mov al, 0b_111_00_0_11                                  ; 9600 P0 S1 B8
    int 0x14

    ; print to bochs console
    mov al, 'I'
    out 0xe9, al

    ; clear segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; clear top 16 bytes below 0000:ffff, which will be the new stack
    mov cx, 16
    mov si, 0xfff0

    ; TODO use loop
    mov word [ds:0xfff0], 0
    mov word [ds:0xfff2], 0
    mov word [ds:0xfff4], 0
    mov word [ds:0xfff6], 0
    mov word [ds:0xfff8], 0
    mov word [ds:0xfffa], 0
    mov word [ds:0xfffc], 0
    mov word [ds:0xfffe], 0

    ; clear rest of the machine state
    xor bx, bx
    xor cx, cx
    xor dx, dx
    xor si, si
    xor di, di
%endif

    ; move stack to 0800:0000, taking care of the return address
    pop bp                                                  ; pop return address from old stack

    mov sp, 0x0800
    mov ss, sp
    xor sp, sp

    push bp                                                 ; push return address to new stack
    xor bp, bp

    ; clear flags
    push ax
    popf

    retn


out_char:                                                   ; al is the char to print
%ifdef BOCHS
    push ax
    push dx

    ; send character to COM1
    mov ah, 0x01                                            ; send character
    mov dx, 0                                               ; COM1
    int 0x14

.wait_serial:
    ; TODO mov ah, 0x03
    mov ax, 0x03                                            ; get status
    int 0x14

    and ah, 0b_01000000                                     ; trans shift reg empty
    ; TODO jnz %wait_serial
    jz .wait_serial

    ; TODO print also to bochs console (or at least print a dot)

    pop dx
    pop ax
%endif

%ifdef VM8086
    ; TODO
%endif

    retn


power_off:
%ifdef BOCHS
    ; apm connect
    mov ax, 0x5301
    xor bx, bx
    int 0x15

    ; apm set version to 1.2
    mov ax, 0x530e
    xor bx, bx
    mov cx, 0x0102
    int 0x15

    ; print to bochs console
    mov al, 'P'
    out 0xe9, al
    mov al, 10
    out 0xe9, al

    ; apm power off
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
%endif

%ifdef VM8086
    ; TODO don't use hlt to stop the vm
    hlt
%endif

    ; we should not ever get here
    jmp $

%ifdef BOCHS

%macro mark 1
    call text_seg:mark_bochs
    db  %1
%endmacro

mark_bochs:
    ; output a mark in raw form, to be formatted later by dump_state.c

.first_push:
    push ax
    push bx
    push bp
    push es
    pushf
.last_push:

    ; reconstruct original sp in bp
    mov bp, sp
    add bp, (.last_push - .first_push) * 2 + 4              ; push * + CS + IP

    ; load return address to ES:BX
    mov bx, [word bp - 2]
    mov es, bx
    mov bx, [word bp - 4]

    ; instead of next instruction, this location contains the mark number
    mov ah, [byte es:bx]

    ; increment the return address to skip the mark number on return
    inc bx
    mov [word bp - 4], bx

    ; record type is 0x0002
    mov al, 0x02
    call out_char
    mov al, 0x00
    call out_char

    ; output the low byte of mark
    mov al, ah
    call out_char

    ; print to bochs console
    mov al, 'M'
    out 0xe9, al

    popf
    pop es
    pop bp
    pop bx
    pop ax

    retf
%elifdef VM8086

%macro mark 1
    ; ask the vm to print the mark
    push ax
    mov al, %1
    out 0x43, al
    pop ax
%endmacro

%endif


%ifdef BOCHS

%macro dump_state 0
    call text_seg:dump_state_bochs
%endmacro

dump_state_bochs:
    ; dump state in raw form, to be formatted later by dump_state.c

.first_push:
    push ax
    push cx
    push si
    push bp
    pushf

    ; save ax, bp and flags for dumping later
    push ax
    push bp
    pushf
.last_push:

    ; reconstruct original sp in bp
    mov bp, sp
    add bp, (.last_push - .first_push) * 2 + 4              ; push * + CS + IP

    ; record type is 0x0001
    mov al, 0x01
    call out_char
    mov al, 0x00
    call out_char

    ; IP is on stack from the function call
    mov ax, word [bp - 4]
    ; we need to decrease IP to match the value in vm8086,
    ; because 'out 0x42, al' is just two bytes and far call is five
    sub ax, 3
    call out_char
    mov al, ah
    call out_char

    ; flags
    pop ax
    call out_char
    mov al, ah
    call out_char

    ; segment registers
    ; c is on stack from the function call
    mov ax, word [bp - 2]
    call out_char
    mov al, ah
    call out_char

    mov ax, ds
    call out_char
    mov al, ah
    call out_char

    mov ax, ss
    call out_char
    mov al, ah
    call out_char

    mov ax, es
    call out_char
    mov al, ah
    call out_char

    ; bp and sp
    pop ax                              ; the real bp that we saved
    call out_char
    mov al, ah
    call out_char

    mov ax, bp                          ; bp actually contains original sp
    call out_char
    mov al, ah
    call out_char

    ; other registers
    pop ax                              ; the real ax that we saved
    call out_char
    mov al, ah
    call out_char

    mov ax, bx
    call out_char
    mov al, ah
    call out_char

    mov ax, cx
    call out_char
    mov al, ah
    call out_char

    mov ax, dx
    call out_char
    mov al, ah
    call out_char

    mov ax, si
    call out_char
    mov al, ah
    call out_char

    mov ax, di
    call out_char
    mov al, ah
    call out_char

    ; top 16 bytes of the stack
    mov cx, 16
    mov si, 0

.loop_stack:
    mov al, byte [bp + si]
    call out_char

    inc si
    loop .loop_stack

    ; print to bochs console
    mov al, 's'
    out 0xe9, al

    popf
    pop bp
    pop si
    pop cx
    pop ax

    retf
%elifdef VM8086

%macro dump_state 0
    out 0x42, al                        ; ask the vm to dump state
    db  3 dup (0x90)                    ; 3x nop to match the length of the far call that bochs uses
%endmacro

%endif

    retn
