.EXPORT print_trace

# From memory.s
.IMPORT read

# From opcodes.s
.IMPORT opcodes

# From state.s
.IMPORT reg_pc

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str

##########
print_trace:
.FRAME opcode, opname, length, idx, tmp
    arb -5

    # Load information from opcodes
    add [reg_pc], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + opcode]

    mul [rb + opcode], 5, [rb + tmp]
    add opcodes, [rb + tmp], [rb + opname]

    add opcodes + 4, [rb + tmp], [ip + 1]
    add [0], 0, [rb + length]

    # Print address
    add [reg_pc], 0, [rb - 1]
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    out ':'
    out ' '

    # Print operation
    add [rb + opname], 0, [rb - 1]
    arb -1
    call print_str

    out '('

    add [rb + opcode], 0, [rb - 1]
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    out ')'

    add 1, 0, [rb + idx]

print_trace_data_loop:
    eq  [rb + idx], [rb + length], [rb + tmp]
    jnz [rb + tmp], print_trace_data_done

    out ' '

    add [reg_pc], [rb + idx], [rb - 1]
    arb -1
    call read

    add [rb - 3], 0, [rb - 1]
    add 16, 0, [rb - 2]
    arb -2
    call print_num_radix

    add [rb + idx], 1, [rb + idx]
    jz  0, print_trace_data_loop

print_trace_data_done:
    out 10

    arb 5
    ret 0
.ENDFRAME

.EOF
