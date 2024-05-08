; SCAS 8-bit

    ; SCAS uses es:di, but the data is in src_seg
    mov ax, src_seg
    mov es, ax

    mov ax, 0x00ab
    mov cx, 0

    mark 0x30

    dump_state

    ; standalone instruction, equal values
    cld
    mov di, value_ab_b - src_addr
    scasb

    dump_state

    ; standalone instruction, different values
    cld
    mov di, value_ab_b_end - src_addr
    scasb

    dump_state

    mark 0x31

    ; REPZ with increment, equal values
    cld
    mov di, value_ab_b - src_addr
    mov cx, 7
    repz scasb

    dump_state

    ; REPZ with increment, all different values
    cld
    mov di, value_ab_b_end - src_addr
    mov cx, 11
    repz scasb

    dump_state

    ; REPZ with increment, some equal values
    cld
    mov di, value_ab_b_end - 5 - src_addr
    mov cx, 13
    repz scasb

    dump_state

    mark 0x32

    ; REPNZ with increment, equal values
    cld
    mov di, value_ab_b - src_addr
    mov cx, 11
    repnz scasb

    dump_state

    ; REPNZ with increment, all different values
    cld
    mov di, value_ab_b_end - src_addr
    mov cx, 13
    repnz scasb

    dump_state

    ; REPNZ with increment, some different values
    cld
    mov di, value_ab_b - 7 - src_addr
    mov cx, 17
    repnz scasb

    dump_state

    mark 0x33

    ; REPZ with decrement, equal values
    std
    mov di, value_ab_b_end - 1 - src_addr
    mov cx, 5
    repz scasb

    dump_state

    ; REPZ with decrement, all different values
    std
    mov di, value_ab_b - 1 - src_addr
    mov cx, 7
    repz scasb

    dump_state

    ; REPZ with decrement, some equal values
    std
    mov di, value_ab_b + 11 - src_addr
    mov cx, 21
    repz scasb

    dump_state

    mark 0x34

    ; REPNZ with decrement, equal values
    std
    mov di, value_ab_b_end - 1 - src_addr
    mov cx, 7
    repnz scasb

    dump_state

    ; REPNZ with decrement, all different values
    std
    mov di, value_ab_b - 1 - src_addr
    mov cx, 13
    repnz scasb

    dump_state

    ; REPNZ with decrement, some different values
    std
    mov di, value_ab_b_end + 7 - src_addr
    mov cx, 11
    repnz scasb

    dump_state

    ; reset es, it was modified at the beginning of this file
    mov ax, dst_seg
    mov es, ax

    cld
