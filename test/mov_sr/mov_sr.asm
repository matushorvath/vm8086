cpu 8086
org 0x00000


section interrupts start=0x00000
    dw  3 dup (0x0000, 0x0000)
    dw  handle_int3, 0xd000             ; INT 3

data_segment:
    dw  0x1234


section .data start=0x12340

test_data:
    dw  0


section .text start=0xd0000

handle_int3:                            ; INT 3 handler
    out 0x42, al

    ; MOV sr, [16-bit displacement]
    mov ds, [data_segment]

    out 0x42, al

    mov [test_data], ds
    mov es, [test_data]

    out 0x42, al

    mov [test_data], es
    mov ss, [test_data]
    mov es, ax                          ; zero es to check the mov es, [] below 

    out 0x42, al

    mov [test_data], ss
    mov es, [test_data]

    out 0x42, al

    ; TODO x proper tests once we are able to fill registers with immediate

    ; MOV sr, [registers]
    mov es, [bx + si]
    mov es, [bx + di]
    mov es, [bp + si]
    mov es, [bp + di]
    mov es, [si]
    mov es, [di]
    mov es, [bp]
    mov es, [bx]

    ; MOV [registers], sr
    mov [bx + si], es
    mov [bx + di], es
    mov [bp + si], es
    mov [bp + di], es
    mov [si], es
    mov [di], es
    mov [bp], es
    mov [bx], es

    out 0x42, al

    ; TODO x MOV sr, MEM16 with 8-bit displacement, both directions
    ; TODO x MOV sr, MEM16 with 16-bit displacement], both directions
    ; TODO x MOV sr, reg, both directions
    ; TODO x test setting cs (as the last test probably)

    hlt


section boot start=0xffff0              ; boot
    int3
