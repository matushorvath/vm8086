.EXPORT port_in_debug
.EXPORT port_out_debug
.EXPORT print_mark

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

##########
port_in_debug:
.FRAME port; value                                          # returns value
    arb -1

    # Input a constant for unmapped ports
    add 0xff, 0, [rb + value]

    # Output port number to stdout
    add port_in_message_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + port], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 1
    ret 1
.ENDFRAME

##########
port_out_debug:
.FRAME port, value;
    # Output the port and value to stdout
    add port_out_message_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + port], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    add port_out_message_separator, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    ret 2
.ENDFRAME

##########
port_in_message_start:
    db  "IN port 0x", 0
port_out_message_start:
    db  "OUT port 0x", 0
port_out_message_separator:
    db  ": 0x", 0

##########
print_mark:
.FRAME port, mark; tmp
    arb -1

    add mark_header, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + mark], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out 10

    arb 1
    ret 2
.ENDFRAME

##########
mark_header:
    db  "----------", 10, "MARK: ", 0

.EOF
