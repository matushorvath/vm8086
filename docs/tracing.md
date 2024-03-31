execute_loop:
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
