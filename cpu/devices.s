.EXPORT handle_interrupt
.EXPORT handle_port_read
.EXPORT handle_port_write
.EXPORT handle_memory_read
.EXPORT handle_memory_write

# Data structures that need to be linked in:
#
# device_interrupts:
#     pointer to a table of 256 records, each 1 byte
#     device_interrupts = { callback }[256]
#
# device_ports:
#     pointer to a two level table of 256 * 256 records, each 2 bytes
#     device_ports = { device_ports_level_2 }[256]
#     device_ports_level_2 = { read_callback, write_callback }[256]
#
# device_regions:
#     pointer to a table of 256 records, each 2 bytes
#     each region represents 4kB of memory
#     device_regions = { read_callback, write_callback }[256]

# From the config file
.IMPORT device_interrupts
.IMPORT device_ports
.IMPORT device_regions

# From util.s
.IMPORT split_20_8_12

# TODO functions to register devices dynamically

##########
handle_interrupt:
.FRAME interrupt; callback, tmp
    arb -2

    # Is there any table at all?
    jz  [device_interrupts], handle_interrupt_done

    # Is there a callback?
    add [device_interrupts], [rb + interrupt], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_interrupt_done

    # Call the callback
    add [rb + interrupt], 0, [rb - 1]
    arb -1
    call [rb + callback + 1]

handle_interrupt_done:
    arb 2
    ret 1
.ENDFRAME

##########
handle_port_read:
.FRAME port; value, table, callback, tmp                    # returns value
    arb -4

    # Is there any table at all?
    jz  [device_ports], handle_port_read_done

    # Is there a second level table?
    add [device_ports], [rb + port], [ip + 1]
    add [0], 0, [rb + table]

    jz  [rb + table], handle_port_read_done

    # Is there a read callback?
    mul [rb + port], 2, [rb + tmp]
    add [rb + table], [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_port_read_done

    # Call the read callback
    add [rb + port], 0, [rb - 1]
    arb -1
    call [rb + callback + 1]
    add [rb - 3], 0, [rb + value]

handle_port_read_done:
    arb 4
    ret 1
.ENDFRAME

##########
handle_port_write:
.FRAME port, value; table, callback, tmp
    arb -3

    # Is there any table at all?
    jz  [device_ports], handle_port_write_done

    # Is there a second level table?
    add [device_ports], [rb + port], [ip + 1]
    add [0], 0, [rb + table]

    jz  [rb + table], handle_port_write_done

    # Is there a write callback?
    mul [rb + port], 2, [rb + tmp]
    add [rb + table], [rb + tmp], [rb + tmp]
    add 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_port_write_done

    # Call the write callback
    add [rb + port], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + callback + 2]

handle_port_write_done:
    arb 3
    ret 2
.ENDFRAME

##########
handle_memory_read:
.FRAME address; value, callback, tmp                       # returns value
    arb -X

    # Is there any table at all?
    jz  [device_regions], handle_memory_read_done

    # Split the address into an 8-bit part and a 12-bit part
    add [rb + address], 0, [rb - 1]
    arb -1
    call split_20_8_12      # [rb - 3] and [rb - 4] are used below

    # Is there a callback?
    mul [rb - 3], 2, [rb + tmp]
    add [device_regions], [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_memory_read_done

    # Call the callback
    add [rb + interrupt], 0, [rb - 1]
    arb -1
    call [rb + callback + 1]

handle_memory_read_done:
    arb X
    ret 1
.ENDFRAME


.EOF
