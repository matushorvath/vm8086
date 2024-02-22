.EXPORT report_error

# From libxib.s
.IMPORT print_str

##########
report_error:
.FRAME message;
    add report_error_msg_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + message], 0, [rb - 1]
    arb -1
    call print_str

    out 10

    hlt

report_error_msg_start:
    db "Error: ", 0
.ENDFRAME

.EOF
