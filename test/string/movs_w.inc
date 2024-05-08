; MOVS 16-bit

    mark 0x90

    ; standalone instruction
    mov si, src_data - src_addr + 11
    mov di, dst_data - dst_addr
    movsw

    dump_state
