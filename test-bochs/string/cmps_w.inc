; CMPS 16-bit

    mov cx, 0

    mark 0x90

    ; prepare destination data
    mov si, src_data - src_addr
    mov di, dst_data - dst_addr
    mov cx, src_data_count
    rep movsb

    dump_state

    ; standalone instruction, equal values
    cld
    mov si, src_data - src_addr + 5
    mov di, dst_data - dst_addr + 5
    cmpsw

    dump_state

    ; standalone instruction, different values
    cld
    mov si, src_data - src_addr + 23
    mov di, dst_data - dst_addr + 21
    cmpsw

    dump_state

    mark 0x91

    ; REPZ with increment, equal values
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 7
    mov cx, 13
    repz cmpsw

    dump_state

    ; REPZ with increment, all different values
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 8
    mov cx, 11
    repz cmpsw

    dump_state

    ; REPZ with increment, one different value
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 7
    mov word [es:di + 22], 0xffff
    mov cx, 17
    repz cmpsw

    dump_state

    ; reset the modified word
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 7
    mov ax, word [es:di + 22]           ; cross check, ax should be 0xffff
    mov dx, word [ds:si + 22]
    mov word [es:di + 22], dx

    dump_state

    mark 0x92

    ; REPNZ with increment, equal values
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 7
    mov cx, 13
    repnz cmpsw

    dump_state

    ; REPNZ with increment, all different values
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 8
    mov cx, 11
    repnz cmpsw

    dump_state

    ; REPNZ with increment, one equal value
    cld
    mov si, src_data - src_addr + 7
    mov di, dst_data - dst_addr + 8
    mov dx, word [ds:si + 22]
    mov word [es:di + 22], dx
    mov cx, 17
    repnz cmpsw

    dump_state

    ; reset the modified word
    mov si, src_data - src_addr + 8
    mov di, dst_data - dst_addr + 8
    mov ax, word [es:di + 22]           ; cross check, ax should be different from dx
    mov dx, word [ds:si + 22]
    mov word [es:di + 22], dx

    dump_state

    mark 0x93

    ; REPZ with decrement, equal values
    std
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 29
    mov cx, 7
    repz cmpsw

    dump_state

    ; REPZ with decrement, all different values
    std
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 30
    mov cx, 13
    repz cmpsw

    dump_state

    ; REPZ with decrement, one different value
    std
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 29
    mov word [es:di - 18], 0xffff
    mov cx, 11
    repz cmpsw

    dump_state

    ; reset the modified word
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 29
    mov ax, word [es:di - 18]           ; cross check, ax should be 0xffff
    mov dx, word [ds:si - 18]
    mov word [es:di - 18], dx

    dump_state

    mark 0x94

    ; REPNZ with decrement, equal values
    std
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 29
    mov cx, 7
    repnz cmpsw

    dump_state

    ; REPNZ with decrement, all different values
    std
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 30
    mov cx, 13
    repnz cmpsw

    dump_state

    ; REPNZ with decrement, one equal value
    std
    mov si, src_data - src_addr + 29
    mov di, dst_data - dst_addr + 30
    mov dx, word [ds:si - 18]
    mov word [es:di - 18], dx
    mov cx, 11
    repnz cmpsw

    dump_state

    ; reset the modified byte
    mov si, src_data - src_addr + 30
    mov di, dst_data - dst_addr + 30
    mov ax, word [es:di - 18]           ; cross check, ax should be different from dx
    mov dx, word [ds:si - 18]
    mov word [es:di - 18], dx

    dump_state

    cld
