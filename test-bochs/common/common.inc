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
section header start=rom_addr
    dw  0xaa55                                              ; signature
    db  rom_size / 0x200                                    ; size in 512 byte blocks
    jmp text_seg:init


; startup and initialization
section .text start=text_addr
init:
    call initialize


%ifdef BOCHS
; dummy section to make sure the image is exactly rom_size bytes long
section image_end start=(rom_addr + rom_size - 1)
    db  0
%endif


%ifdef VM8086
boot_addr   equ 0xffff0

; the CPU starts here at ffff:0000
section boot start=boot_addr
    jmp text_seg:init

    ; to have a round file size, fill the image up to 0x100000
    db  (0x100000 - boot_addr) - ($ - $$) dup 0
%endif


; utilities

section util start=util_addr

initialize:
%ifdef BOCHS
    ; mark start of output on bochs console
    mov al, '>'
    out 0xe9, al
    mov al, '>'
    out 0xe9, al
    mov al, '>'
    out 0xe9, al
    mov al, ' '
    out 0xe9, al

    ; clear segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; clear top 16 bytes below 0000:ffff, which will be the new stack
    mov cx, 8
    mov si, 0xfff0

.clear_loop:
    mov word [ds:si], 0
    add si, 2
    loop .clear_loop

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


power_off:
%ifdef BOCHS
    ; mark end of output on bochs console
    mov al, '<'
    out 0xe9, al
    mov al, '<'
    out 0xe9, al
    mov al, '<'
    out 0xe9, al
    mov al, 10
    out 0xe9, al
%endif

    ; output 'Shutdown' to port 0x8900
    ; TODO use outsb once available
    mov dx, 0x8900
    mov si, 0x00

.loop_char:
    mov al, [cs:.shutdown_string + si]
    cmp al, 0x00
    je  .loop_done

    out dx, al
    inc si
    jmp .loop_char

.loop_done:
    ; we should never get here
    jmp $

.shutdown_string:
    db  "Shutdown", 0


out_char:                                                   ; al is the char to print
%ifdef BOCHS
    push ax
    push cx

    mov ah, al

    and al, 0xf0
    mov cl, 4
    shr al, cl
    add al, '0'
    cmp al, '9'
    jle .out_hi
    add al, 7
.out_hi:
    out 0xe9, al

    mov al, ah

    and al, 0x0f
    add al, '0'
    cmp al, '9'
    jle .out_lo
    add al, 7
.out_lo:
    out 0xe9, al

    mov al, ' '
    out 0xe9, al

    pop cx
    pop ax
    retn
%elifdef VM8086
    ; TODO implement out_char for vm8086
%endif


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
    mov bx, [bp - 2]
    mov es, bx
    mov bx, [bp - 4]

    ; instead of next instruction, this location contains the mark number
    mov ah, [es:bx]

    ; increment the return address to skip the mark number on return
    inc bx
    mov [bp - 4], bx

    ; record type is 0x0002
    mov al, 0x02
    call out_char
    mov al, 0x00
    call out_char

    ; output the low byte of mark
    mov al, ah
    call out_char

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
