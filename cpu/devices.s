#.EXPORT register_interrupt
.EXPORT register_port
#.EXPORT register_memory

#.EXPORT handle_interrupt
.EXPORT handle_port_read
.EXPORT handle_port_write
#.EXPORT handle_memory_read
#.EXPORT handle_memory_write

# From error.s
.IMPORT report_error

# TODO optimize data structures for speed, e.g. a hash table
# TODO check for duplicate registration (same port/interrupt/overlapping region already registered)

##########
#interrupts:
#    # interrupt, callback
#.SYMBOL INTERRUPTS_SIZE 32 # = INTERRUPT_LENGTH * 16
#.SYMBOL INTERRUPT_LENGTH 2
#    ds  32, 0

ports:
    # port, read callback, write callback
.SYMBOL PORTS_SIZE 768  # = PORT_LENGTH * 256
.SYMBOL PORT_LENGTH 3
    ds  768, 0

regions:
    # start address, stop address, read callback, write callback
.SYMBOL REGIONS_SIZE 64 # = REGIONY_LENGTH * 16
.SYMBOL REGIONY_LENGTH 4
    ds  64, 0

##########
register_port:
.FRAME port, read_callback, write_callback; rec_ptr, tmp
    arb -2

    add ports, 0, [rb + rec_ptr]

register_port_loop:
    add [rb + rec_ptr], 0, [ip + 1]
    jz  [0], register_port_empty_found

    add [rb + rec_ptr], PORT_LENGTH, [rb + rec_ptr]

    lt  [rb + rec_ptr], PORTS_SIZE, [rb + tmp]
    jnz [rb + tmp], register_port_loop

    # No free space in the table
    add register_port_no_space, 0, [rb - 1]
    arb -1
    call report_error

register_port_empty_found:
    # Create a new record
    add [rb + rec_ptr], 0, [ip + 3]
    add [rb + port], 0, [0]

    add [rb + rec_ptr], 1, [ip + 3]
    add [rb + read_callback], 0, [0]

    add [rb + rec_ptr], 2, [ip + 3]
    add [rb + write_callback], 0, [0]

    arb 2
    ret 3

register_port_no_space:
    db  "Cannot register port; no free space in the table", 0
.ENDFRAME

##########
handle_port_read:
.FRAME port; value, rec_ptr, tmp                            # returns value
    arb -3

    add ports, 0, [rb + rec_ptr]

handle_port_read_loop:
    add [rb + rec_ptr], 0, [ip + 1]
    eq  [0], [rb + port], [rb + tmp]
    jnz [rb + tmp], handle_port_read_found

    add [rb + rec_ptr], PORT_LENGTH, [rb + rec_ptr]

    lt  [rb + rec_ptr], PORTS_SIZE, [rb + tmp]
    jnz [rb + tmp], handle_port_read_loop

    jz  0, handle_port_read_done

handle_port_read_found:
    # Call the read callback
    add [rb + rec_ptr], 1, [ip + 1]
    add [0], 0, [rb + tmp]

    add [rb + port], 0, [rb - 1]
    arb -1
    call [rb + tmp + 1]
    add [rb - 3], 0, [rb + value]

handle_port_read_done:
    arb 3
    ret 1
.ENDFRAME

##########
handle_port_write:
.FRAME port, value; rec_ptr, tmp
    arb -2

    add ports, 0, [rb + rec_ptr]

handle_port_write_loop:
    add [rb + rec_ptr], 0, [ip + 1]
    eq  [0], [rb + port], [rb + tmp]
    jnz [rb + tmp], handle_port_write_found

    add [rb + rec_ptr], PORT_LENGTH, [rb + rec_ptr]

    lt  [rb + rec_ptr], PORTS_SIZE, [rb + tmp]
    jnz [rb + tmp], handle_port_write_loop

    jz  0, handle_port_write_done

handle_port_write_found:
    # Call the write callback
    add [rb + rec_ptr], 2, [ip + 1]
    add [0], 0, [rb + tmp]

    add [rb + port], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + tmp + 2]

handle_port_write_done:
    arb 2
    ret 2
.ENDFRAME

.EOF
