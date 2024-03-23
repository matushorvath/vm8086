    ; set ds to access the data
    mov ax, 0x1000
    mov ds, ax

    ; set also ss and sp, so we can see the data in state dump
    mov ax, 0x1000
    mov ss, ax
    mov sp, data

    ; reset the memory
    mov byte [data + 0], 0xaaaa
    mov byte [data + 1], 0xaaaa
    mov byte [data + 2], 0xaaaa
    mov byte [data + 3], 0xaaaa
    mov byte [data + 4], 0xaaaa
    mov byte [data + 5], 0xaaaa
    mov byte [data + 6], 0xaaaa
    mov byte [data + 7], 0xaaaa

    ; set up registers we will use
    mov bx, data
    mov bp, data
    mov si, 2

    ; increment 8-bit memory using various addressing modes
    inc byte [data]
    inc byte [bx + 1]
    inc byte [bp + 2]
    inc byte [bx + si + 1]

    out 0x42, al

    ; increment 16-bit memory using various addressing modes
    inc word [data]
    inc word [bx + 2]
    inc word [bp + 4]
    inc word [bx + si + 4]

    out 0x42, al

    ; reset the memory
    mov byte [data + 0], 0x8888
    mov byte [data + 1], 0x8888
    mov byte [data + 2], 0x8888
    mov byte [data + 3], 0x8888
    mov byte [data + 4], 0x8888
    mov byte [data + 5], 0x8888
    mov byte [data + 6], 0x8888
    mov byte [data + 7], 0x8888

    ; decrement 8-bit memory using various addressing modes
    dec byte [data]
    dec byte [bx + 1]
    dec byte [bp + 2]
    dec byte [bx + si + 1]

    out 0x42, al

    ; decrement 16-bit memory using various addressing modes
    dec word [data]
    dec word [bx + 2]
    dec word [bp + 4]
    dec word [bx + si + 4]

    out 0x42, al
