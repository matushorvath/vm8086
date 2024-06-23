.EXPORT log_cs_change

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip

# From libxib.a
.IMPORT print_str
.IMPORT print_num_16_w

##########
log_cs_change:
.FRAME cs, tmp
    arb -2

    # Only log when CS changed
    mul [reg_cs + 1], 0x100, [rb + cs]
    add [reg_cs + 1], [rb + cs], [rb + cs]

    eq  [rb + cs], [prev_cs], [rb + tmp]
    jnz [rb + tmp], log_cs_change_done

    add [rb + cs], 0, [prev_cs]

    # Print the log message
    add log_cs_change_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + cs], 0, [rb - 1]
    arb -1
    call print_num_16_w

    out ':'

    mul [reg_ip + 1], 0x100, [rb - 1]
    add [reg_ip + 1], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    out 10

log_cs_change_done:
    arb 2
    ret 0

log_cs_change_start:
    db  31, 31, 31, "write CS: ", 0
.ENDFRAME

##########
prev_cs:
    db  0

.EOF
