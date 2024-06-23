.EXPORT interrupt_request_log
.EXPORT pic_command_write_log
.EXPORT pic_data_write_log
.EXPORT pic_status_read_log
.EXPORT pic_data_read_log

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_16_b

##########
interrupt_request_log:
.FRAME number;
    add interrupt_request_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + number], 0, [rb - 1]
    arb -1
    call print_num

    out 10
    ret 1

interrupt_request_log_start:
    db  31, 31, 31, "pic irq ", 0
.ENDFRAME

##########
pic_command_write_log:
.FRAME value;
    add pic_command_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_command_write_log_start:
    db  31, 31, 31, "pic command write: value 0x", 0
.ENDFRAME

##########
pic_data_write_log:
.FRAME value;
    add pic_data_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_data_write_log_start:
    db  31, 31, 31, "pic data write: value 0x", 0
.ENDFRAME

##########
pic_status_read_log:
.FRAME value;
    add pic_status_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_status_read_log_start:
    db  31, 31, 31, "pic status read: value 0x", 0
.ENDFRAME

##########
pic_data_read_log:
.FRAME value;
    add pic_data_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_data_read_log_start:
    db  31, 31, 31, "pic data read: value 0x", 0
.ENDFRAME

.EOF
