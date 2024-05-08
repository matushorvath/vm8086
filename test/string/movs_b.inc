; MOVS 8-bit

    ; standalone instruction
    mov si, src_data - src_addr + 5
    mov di, dst_data - dst_addr
    movsb

    dump_state
