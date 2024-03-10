.EXPORT report_error

# From state.s
.IMPORT reg_pc

# From libxib.s
.IMPORT print_num_radix
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
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    add report_error_msg_end, 0, [rb - 1]
    arb -1
    call print_str

    out 10

    hlt

report_error_msg_start:
    db "vm8086 error: ", 0
report_error_msg_pc:
    db " (pc: ", 0
report_error_msg_end:
    db ")", 0
.ENDFRAME

.EOF
