.EXPORT print_trace

# From memory.s
.IMPORT read

# From instructions.s
.IMPORT instructions

# From state.s
.IMPORT reg_ip

# From libxib.a
.IMPORT print_num_radix
.IMPORT print_str







##########
execute:
.FRAME tmp, op
    arb -2

execute_loop:
# TODO tracing
#    # Skip tracing if disabled
#    jz  [binary_enable_tracing], execute_tracing_done
#
#    # If the [binary_enable_tracing] flag is positive, we use it as an address
#    # starting from where we should turn on tracing
#    eq  [binary_enable_tracing], [reg_ipxxx], [rb + tmp]
#    jz  [rb + tmp], execute_tracing_different_address
#
#    # Address match, turn on tracing
#    add -1, 0, [binary_enable_tracing]
#
#execute_tracing_different_address:
#    # Print trace if enabled
#    eq  [binary_enable_tracing], -1, [rb + tmp]
#    jz  [rb + tmp], execute_tracing_done
#
#    call print_trace
#
#execute_tracing_done:
#    # Call the callback if enabled
#    jz  [binary_vm_callback], execute_callback_done
#
#    call [binary_vm_callback]
#    jnz [rb - 2], execute_callback_done
#
#    # Callback returned 0, halt
#    jz  0, execute_hlt
#
#execute_callback_done:
    # Handle prefixes; first check if they were consumed (prefix_valid == 0)
    jz  [prefix_valid], execute_prefix_done

    # Decrease prefix lifetime
    add [prefix_valid], -1, [prefix_valid]

    # If now prefix_valid == 0, we have just used the prefixes, reset them to defaults
    jnz [prefix_valid], execute_prefix_done

    add reg_ds, 0, [ds_segment_prefix]
    add reg_ss, 0, [ss_segment_prefix]
    add 0, 0, [rep_prefix]

execute_prefix_done:
    # Read op code
    call read_cs_ip_b
    add [rb - 2], 0, [rb + op]









##########
print_trace:
.FRAME opcode, opname, length, idx, tmp
    arb -5

    # Load information from instructions
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + opcode]

    mul [rb + opcode], 7, [rb + tmp]                        # one record is 7 bytes long
    add instructions + 0, [rb + tmp], [rb + opname]         # instruction name is at index 0 in the record

    add instructions + 4, [rb + tmp], [ip + 1]              # instruction length is at index 4 in the record
    add [0], 0, [rb + length]

    # Print address
    add [reg_ip], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
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
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ')'

    add 1, 0, [rb + idx]

print_trace_data_loop:
    eq  [rb + idx], [rb + length], [rb + tmp]
    jnz [rb + tmp], print_trace_data_done

    out ' '

    add [reg_ip], [rb + idx], [rb - 1]
    arb -1
    call read

    add [rb - 3], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 0, 0, [rb - 3]
    arb -3
    call print_num_radix

    add [rb + idx], 1, [rb + idx]
    jz  0, print_trace_data_loop

print_trace_data_done:
    out 10

    arb 5
    ret 0
.ENDFRAME

.EOF
