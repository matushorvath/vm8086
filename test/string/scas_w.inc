; SCAS 16-bit

    ; SCAS uses es:di, but the data is in src_seg
    mov ax, src_seg
    mov es, ax

    mov ax, 0xcdef
    mov cx, 0

    mark 0xa0

    dump_state

    ; standalone instruction, equal values
    cld
    mov di, value_cdef_w - src_addr
    scasw

    dump_state

    ; standalone instruction, different values
    cld
    mov di, value_cdef_w_end - src_addr
    scasw

    dump_state

    mark 0xa1

    ; REPZ with increment, equal values
    cld
    mov di, value_cdef_w - src_addr
    mov cx, 7
    repz scasw

    dump_state

    ; REPZ with increment, all different values
    cld
    mov di, value_cdef_w_end - src_addr
    mov cx, 11
    repz scasw

    dump_state

    ; REPZ with increment, some equal values
    cld
    mov di, value_cdef_w_end - 6 - src_addr
    mov cx, 13
    repz scasw

    dump_state

    mark 0xa2

    ; REPNZ with increment, equal values
    cld
    mov di, value_cdef_w - src_addr
    mov cx, 11
    repnz scasw

    dump_state

    ; REPNZ with increment, all different values
    cld
    mov di, value_cdef_w_end - src_addr
    mov cx, 13
    repnz scasw

    dump_state

    ; REPNZ with increment, some different values
    cld
    mov di, value_cdef_w - 8 - src_addr
    mov cx, 17
    repnz scasw

    dump_state

    mark 0xa3

    ; REPZ with decrement, equal values
    std
    mov di, value_cdef_w_end - 2 - src_addr
    mov cx, 5
    repz scasw

    dump_state

    ; REPZ with decrement, all different values
    std
    mov di, value_cdef_w - 2 - src_addr
    mov cx, 7
    repz scasw

    dump_state

    ; REPZ with decrement, some equal values
    std
    mov di, value_cdef_w + 12 - src_addr
    mov cx, 21
    repz scasw

    dump_state

    mark 0xa4

    ; REPNZ with decrement, equal values
    std
    mov di, value_cdef_w_end - 2 - src_addr
    mov cx, 7
    repnz scasw

    dump_state

    ; REPNZ with decrement, all different values
    std
    mov di, value_cdef_w - 2 - src_addr
    mov cx, 13
    repnz scasw

    dump_state

    ; REPNZ with decrement, some different values
    std
    mov di, value_cdef_w_end + 8 - src_addr
    mov cx, 11
    repnz scasw

    dump_state

    ; reset es, it was modified at the beginning of this file
    mov ax, dst_seg
    mov es, ax

    cld
