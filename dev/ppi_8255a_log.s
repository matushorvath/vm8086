.EXPORT ppi_mode_write_log
.EXPORT ppi_mode_read_log
.EXPORT ppi_port_a_read_log
.EXPORT ppi_port_b_read_log
.EXPORT ppi_port_b_write_log
.EXPORT ppi_port_c_read_log

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_2_b
.IMPORT print_num_16_b

##########
ppi_mode_write_log:
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
    db  "ppi mode write: value 0x", 0
.ENDFRAME

##########
ppi_mode_read_log:
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
    db  "ppi mode read:  value 0x", 0
.ENDFRAME

##########
ppi_port_a_read_log:
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
    db  "ppi port a read:  value 0x", 0
.ENDFRAME

##########
ppi_port_b_write_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "ppi port b write: value 0b", 0
.ENDFRAME

##########
ppi_port_b_read_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "ppi port b read:  value 0b", 0
.ENDFRAME

##########
ppi_port_c_read_log:
.FRAME value;
    call log_start

    add .msg, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

.msg:
    db  "ppi port c read:  value 0b", 0
.ENDFRAME

.EOF
