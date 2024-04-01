.EXPORT print_trace

# From memory.s
.IMPORT calc_cs_ip_addr
.IMPORT read_b

# From trace_data.s
.IMPORT trace_data

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

##########
print_trace:
.FRAME cs_ip, opcode, param_type, index, tmp
    arb -5

    # Calculate physical address from CS:IP
    call calc_cs_ip_addr
    add [rb - 2], 0, [rb + cs_ip]

    # Read opcode
    add [rb + cs_ip], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + opcode]

    # Print address
    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    add 16, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ':'

    mul [reg_ip + 1], 0x100, [rb - 1]
    add [reg_ip + 0], [rb - 1], [rb - 1]
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

print_trace_params_loop:
    mul [rb + opcode], 7, [rb + tmp]                        # one trace_data record is 7 bytes long
    add trace_data, [rb + tmp], [rb + tmp]
    add [rb + index], [rb + tmp], [ip + 1]                  # get index-th parameter, index starts at 1
    add [0], 0, [rb + param_type]

    # Zero parameter means no more parameters
    jz  [rb + param_type], print_trace_params_done

    out ' '

    # Read the parameter value
    add [rb + cs_ip], [rb + index], [rb - 1]
    arb -1
    call read_b

    # Print parameter value
    # TODO decode the parameters
    add [rb - 3], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    add [rb + index], 1, [rb + index]
    jz  0, print_trace_params_loop

print_trace_params_done:
    out 10

    arb 5
    ret 0
.ENDFRAME

.EOF
