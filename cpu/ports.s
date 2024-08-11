.EXPORT register_port
.EXPORT register_ports

.EXPORT handle_port_read
.EXPORT handle_port_write

# From libxib.a
.IMPORT sbrk
.IMPORT zeromem

##########
register_ports:
.FRAME ports; record, tmp
    arb -2

    # Expect an array of 4 byte records (port_lo, port_hi, read_callback, write_callback)
    # terminated by a record of four -1s.

    add [rb + ports], 0, [rb + record]

.loop:
    # Load next record and register the port
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb - 1]

    eq  [rb - 1], -1, [rb + tmp]
    jnz [rb + tmp], .done

    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb - 2]
    add [rb + record], 2, [ip + 1]
    add [0], 0, [rb - 3]
    add [rb + record], 3, [ip + 1]
    add [0], 0, [rb - 4]

    arb -4
    call register_port

    add [rb + record], 4, [rb + record]

    jz  0, .loop

.done:
    arb 2
    ret 1
.ENDFRAME

##########
register_port:
.FRAME port_lo, port_hi, read_callback, write_callback; table, ptr
    arb -2

    # Is there any table at all?
    jnz [device_ports], .have_first_table

    # No, create one
    add 0x100, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [device_ports]

    add [device_ports], 0, [rb - 1]
    add 0x100, 0, [rb - 2]
    arb -2
    call zeromem

.have_first_table:
    # Is there a second level table?
    add [device_ports], [rb + port_hi], [ip + 1]
    add [0], 0, [rb + table]

    jnz [rb + table], .have_second_table

    # No, create one
    add 0x200, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [rb + table]

    add [rb + table], 0, [rb - 1]
    add 0x200, 0, [rb - 2]
    arb -2
    call zeromem

    # Link second level table
    add [device_ports], [rb + port_hi], [ip + 3]
    add [rb + table], 0, [0]

.have_second_table:
    # Save read callback
    mul [rb + port_lo], 2, [rb + ptr]
    add [rb + table], [rb + ptr], [ip + 3]
    add [rb + read_callback], 0, [0]

    # Save write callback
    add [rb + ptr], 1, [rb + ptr]
    add [rb + table], [rb + ptr], [ip + 3]
    add [rb + write_callback], 0, [0]

    arb 2
    ret 4
.ENDFRAME

##########
handle_port_read:
.FRAME port_lo, port_hi; value, table, callback, tmp        # returns value
    arb -4

    # Is there any table at all?
    jz  [device_ports], .unmapped

    # Is there a second level table?
    add [device_ports], [rb + port_hi], [ip + 1]
    add [0], 0, [rb + table]

    jz  [rb + table], .unmapped

    # Is there a read callback?
    mul [rb + port_lo], 2, [rb + tmp]
    add [rb + table], [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], .unmapped

    # Call the read callback
    mul [rb + port_hi], 0x100, [rb - 1]
    add [rb + port_lo], [rb - 1], [rb - 1]
    arb -1
    call [rb + callback + 1]
    add [rb - 3], 0, [rb + value]

    jz  0, .done

.unmapped:
    # Input a constant for unmapped ports
    add 0xff, 0, [rb + value]

.done:
    arb 4
    ret 2
.ENDFRAME

##########
handle_port_write:
.FRAME port_lo, port_hi, value; table, callback, tmp
    arb -3

    # Is there any table at all?
    jz  [device_ports], .done

    # Is there a second level table?
    add [device_ports], [rb + port_hi], [ip + 1]
    add [0], 0, [rb + table]

    jz  [rb + table], .done

    # Is there a write callback?
    mul [rb + port_lo], 2, [rb + tmp]
    add [rb + table], [rb + tmp], [rb + tmp]
    add 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], .done

    # Call the write callback
    mul [rb + port_hi], 0x100, [rb - 1]
    add [rb + port_lo], [rb - 1], [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + callback + 2]

.done:
    arb 3
    ret 3
.ENDFRAME

##########
# Data structures:

# Pointer to a two level table of 256 * 256 records, each 2 bytes
# device_ports_level_1 = { device_ports_level_2 }[256]
# device_ports_level_2 = { read_callback, write_callback }[256]
device_ports:
    db  0

.EOF
