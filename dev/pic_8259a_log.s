.EXPORT interrupt_request_log
.EXPORT pic_command_write_log
.EXPORT pic_data_write_log
.EXPORT pic_status_read_log
.EXPORT pic_data_read_log

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_16_b

##########
interrupt_request_log:
.FRAME number;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + number], 0, [rb - 1]
    arb -1
    call print_num

    out 10
    ret 1

.msg:
    db  "pic irq ", 0
.ENDFRAME

##########
pic_command_write_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

.msg:
    db  "pic command write: value 0x", 0
.ENDFRAME

##########
pic_data_write_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

.msg:
    db  "pic data write: value 0x", 0
.ENDFRAME

##########
pic_status_read_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

.msg:
    db  "pic status read: value 0x", 0
.ENDFRAME

##########
pic_data_read_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

.msg:
    db  "pic data read: value 0x", 0
.ENDFRAME

.EOF
