.EXPORT report_error

# From cpu/state.s
.IMPORT reg_ip
.IMPORT reg_cs

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

##########
report_error:
.FRAME message;
    add .start_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + message], 0, [rb - 1]
    arb -1
    call print_str

    add .cs_ip_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    add 16, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ':'

    mul [reg_ip + 1], 0x100, [rb - 1]
    add [reg_ip + 0], [rb - 1], [rb - 1]
    add 16, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add .end_msg, 0, [rb - 1]
    arb -1
    call print_str

    out 10

    hlt

.start_msg:
    db  "vm8086 error: ", 0
.cs_ip_msg:
    db  " (cs:ip ", 0
.end_msg:
    db  ")", 0
.ENDFRAME

.EOF
