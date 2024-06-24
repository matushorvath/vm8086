.EXPORT log_cs_change

# From state.s
.IMPORT reg_cs

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str

##########
log_cs_change:
.FRAME cs, tmp
    arb -2

    # Only log when CS changed
    mul [reg_cs + 1], 0x100, [rb + cs]
    add [reg_cs + 0], [rb + cs], [rb + cs]

    eq  [rb + cs], [prev_cs], [rb + tmp]
    jnz [rb + tmp], log_cs_change_done
    add [rb + cs], 0, [prev_cs]

    call log_start

    # Print the log message
    add log_cs_change_msg, 0, [rb - 1]
    arb -1
    call print_str

    out 10

log_cs_change_done:
    arb 2
    ret 0

log_cs_change_msg:
    db  "CS changed", 0
.ENDFRAME

##########
prev_cs:
    db  0

.EOF
