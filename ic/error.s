.EXPORT report_error

# From state.s
.IMPORT reg_pc

# From libxib.s
.IMPORT print_num
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

    add report_error_msg_pc, 0, [rb - 1]
    arb -1
    call print_str

    add [reg_pc], 0, [rb - 1]
    arb -1
    call print_num

    add report_error_msg_pc, 0, [rb - 1]
    arb -1
    call print_str

    out 10

    hlt

report_error_msg_start:
    db "Error: ", 0
report_error_msg_pc:
    db " (pc: ", 0
report_error_msg_end:
    db ")", 0
.ENDFRAME

.EOF
