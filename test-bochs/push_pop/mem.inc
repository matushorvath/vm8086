    ; set ds to access the data
    mov ax, bss_seg
    mov ds, ax

    ; reset the memory
    mov word [data + 0], 0x111a
    mov word [data + 1], 0x111b
    mov word [data + 2], 0x111c

    ; set up registers we will use
    mov bp, data
    mov di, 2

    ; push memory
    push word [data]
    push word [ds:bp + 1]
    push word [ds:bp + di]

    dump_state

    ; pop memory in opposite order
    pop word [data]
    pop word [ds:bp + 1]
    pop word [ds:bp + di]

    ; load the values to registers to see them in state dump
    mov word ax, [data]
    mov word bx, [ds:bp + 1]
    mov word cx, [ds:bp + 2]

    dump_state
