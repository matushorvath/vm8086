; SCAS 8-bit

    ; SCAS uses es:di, but the data is in src_seg
    mov ax, src_seg
    mov es, ax

    mov ax, 0x00ab
    mov cx, 0

    mark 0x30

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

    ; mark 0x31

    ; ; REPZ with increment, equal values
    ; cld
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 7
    ; mov cx, 13
    ; repz scasb

    ; dump_state

    ; ; REPZ with increment, all different values
    ; cld
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 8
    ; mov cx, 11
    ; repz scasb

    ; dump_state

    ; ; REPZ with increment, one different value
    ; cld
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 7
    ; mov byte [es:di + 13], 0xff
    ; mov cx, 17
    ; repz scasb

    ; dump_state

    ; ; reset the modified byte
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 7
    ; mov al, byte [es:di + 13]           ; cross check, al should be 0xff
    ; mov dl, byte [ds:si + 13]
    ; mov byte [es:di + 13], dl

    ; dump_state

    ; mark 0x32

    ; ; REPNZ with increment, equal values
    ; cld
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 7
    ; mov cx, 13
    ; repnz scasb

    ; dump_state

    ; ; REPNZ with increment, all different values
    ; cld
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 8
    ; mov cx, 11
    ; repnz scasb

    ; dump_state

    ; ; REPNZ with increment, one equal value
    ; cld
    ; mov si, src_data - src_addr + 7
    ; mov di, dst_data - dst_addr + 8
    ; mov dl, byte [ds:si + 13]
    ; mov byte [es:di + 13], dl
    ; mov cx, 17
    ; repnz scasb

    ; dump_state

    ; ; reset the modified byte
    ; mov si, src_data - src_addr + 8
    ; mov di, dst_data - dst_addr + 8
    ; mov al, byte [es:di + 13]           ; cross check, al should be 0xff
    ; mov dl, byte [ds:si + 13]
    ; mov byte [es:di + 13], dl

    ; dump_state

    ; mark 0x33

    ; ; REPZ with decrement, equal values
    ; std
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 29
    ; mov cx, 7
    ; repz scasb

    ; dump_state

    ; ; REPZ with decrement, all different values
    ; std
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 30
    ; mov cx, 13
    ; repz scasb

    ; dump_state

    ; ; REPZ with decrement, one different value
    ; std
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 29
    ; mov byte [es:di - 17], 0xff
    ; mov cx, 21
    ; repz scasb

    ; dump_state

    ; ; reset the modified byte
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 29
    ; mov al, byte [es:di - 17]           ; cross check, al should be different from dl
    ; mov dl, byte [ds:si - 17]
    ; mov byte [es:di - 17], dl

    ; dump_state

    ; mark 0x34

    ; ; REPNZ with decrement, equal values
    ; std
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 29
    ; mov cx, 7
    ; repnz scasb

    ; dump_state

    ; ; REPNZ with decrement, all different values
    ; std
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 30
    ; mov cx, 13
    ; repnz scasb

    ; dump_state

    ; ; REPNZ with decrement, one equal value
    ; std
    ; mov si, src_data - src_addr + 29
    ; mov di, dst_data - dst_addr + 30
    ; mov dl, byte [ds:si - 17]
    ; mov byte [es:di - 17], dl
    ; mov cx, 21
    ; repnz scasb

    ; dump_state

    ; ; reset the modified byte
    ; mov si, src_data - src_addr + 30
    ; mov di, dst_data - dst_addr + 30
    ; mov al, byte [es:di - 17]           ; cross check, al should be different from dl
    ; mov dl, byte [ds:si - 17]
    ; mov byte [es:di - 17], dl

    ; dump_state

    ; reset es, it was modified at the beginning of this file
    mov ax, dst_seg
    mov es, ax

    cld
