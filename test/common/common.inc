%ifndef BOCHS
%ifndef VM8086
    %error "Neither BOCHS nor VM8086 was defined."
%endif
%endif


text_seg     equ 0xd000
text_addr    equ (text_seg * 0x10)
text_size    equ 0x3000

util_seg    equ 0xd300
util_addr   equ (util_seg * 0x10)
util_size   equ 0x1000

code_size   equ text_size + util_size


cpu 8086
org text_addr


; startup and initialization

section .text start=text_addr
    ; option rom signature, needed for booting in bochs
    dw  0xaa55                                              ; signature
    db  code_size / 0x200                                   ; size in 512 byte blocks

init:
    call initialize


%ifdef BOCHS
section image_end start=(text_addr + code_size - 1)
    ; dummy section to make sure the image is exactly code_size bytes long
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

    ; clear segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; clear top 16 bytes below 0000:ffff, which will be the new stack
    mov cx, 16
    mov si, 0xfff0

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

%macro dump_state 0
    call dump_state_bochs
%endmacro

dump_state_bochs:
    ; dump state in raw form, to be formatted later by dump_state.c

    push ax
    push cx
    push si
    push bp

    ; save ax and bp for dumping later
    push ax
    push bp

    ; reconstruct original sp in bp
    mov bp, sp
    add bp, 14                          ; 6 pushed registers + IP

    ; record type is 0x0001
    mov al, 0x01
    call out_char
    mov al, 0x00
    call out_char

    ; ip is on stack from the function call
    mov ax, word [bp - 2]
    ; we need to decrease to match the value in vm8086, because 'out 0x42, al' is just 2 bytes
    dec ax
    call out_char
    mov al, ah
    call out_char

    ; flags
    pushf
    pop ax
    call out_char
    mov al, ah
    call out_char

    ; segment registers
    mov ax, cs
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

    pop bp
    pop si
    pop cx
    pop ax
%endif

%ifdef VM8086

%macro dump_state 0
    out 0x42, al                    ; ask the vm to dump state
    nop                             ; to match the length of the near call that bochs uses
%endmacro

%endif

    retn
