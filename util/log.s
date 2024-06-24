.EXPORT log_start

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip

# From libxib.a
.IMPORT print_num_16_w

##########
log_start:
.FRAME
    out 31
    out 31
    out 31

    out '('

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    out ':'

    mul [reg_ip + 1], 0x100, [rb - 1]
    add [reg_ip + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    out ')'
    out ' '

    ret 0
.ENDFRAME

.EOF
