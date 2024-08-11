.EXPORT print_trace

# From memory.s
.IMPORT read_seg_off_b

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip

# From trace_data.s
.IMPORT trace_data

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

##########
print_trace:
.FRAME seg, off, opcode, param_type, index, tmp
    arb -6

    # Print the logger mark
    out 31
    out 31
    out 31

    # Calculate segment and offset
    mul [reg_cs + 1], 0x100, [rb + seg]
    add [reg_cs + 0], [rb + seg], [rb + seg]
    mul [reg_ip + 1], 0x100, [rb + off]
    add [reg_ip + 0], [rb + off], [rb + off]

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call read_seg_off_b
    add [rb - 4], 0, [rb + opcode]

    # Print address
    add [rb + seg], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ':'

    add [rb + off], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ' '

    # Print instruction description and opcode
    mul [rb + opcode], 7, [rb + tmp]                        # one trace_data record is 7 bytes long
    add trace_data + 0, [rb + tmp], [ip + 1]                # instruction name pointer is at index 0 of the record
    add [0], 0, [rb - 1]
    arb -1
    call print_str

    out '('

    add [rb + opcode], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ')'

    # Print parameters
    add 1, 0, [rb + index]

.params_loop:
    mul [rb + opcode], 7, [rb + tmp]                        # one trace_data record is 7 bytes long
    add trace_data, [rb + tmp], [rb + tmp]
    add [rb + index], [rb + tmp], [ip + 1]                  # get index-th parameter, index starts at 1
    add [0], 0, [rb + param_type]

    # Zero parameter means no more parameters
    jz  [rb + param_type], .params_done

    out ' '

    # Read the parameter value
    # TODO wrap-around, don't just increase [rb + off]
    add [rb + seg], 0, [rb - 1]
    add [rb + off], [rb + index], [rb - 2]
    arb -2
    call read_seg_off_b

    # Print parameter value
    # TODO decode the parameters
    add [rb - 4], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    add [rb + index], 1, [rb + index]
    jz  0, .params_loop

.params_done:
    out 10

    arb 6
    ret 0
.ENDFRAME

.EOF
