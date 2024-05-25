.EXPORT handle_port_read
.EXPORT handle_port_write
.EXPORT handle_memory_read
.EXPORT handle_memory_write

# From the config file
.IMPORT device_ports
.IMPORT device_regions

# From the config file
.IMPORT config_io_port_debugging

# Data structures that need to be linked in:
#
# device_ports:
#     pointer to a two level table of 256 * 256 records, each 2 bytes
#     device_ports = { device_ports_level_2 }[256]
#     device_ports_level_2 = { read_callback, write_callback }[256]
#
# device_regions:
#     pointer to a table of records, each 4 bytes
#     records must not overlap, and must be sorted by start_addr
#     last record must be all zeros
#     device_regions = { start_addr, stop_addr, read_callback, write_callback }[16]

# TODO functions to register devices dynamically

##########
handle_port_read:
.FRAME port_lo, port_hi; value, table, callback, tmp        # returns value
    arb -4

    # Is there any table at all?
    jz  [device_ports], handle_port_read_unmapped

    # Is there a second level table?
    add [device_ports], [rb + port_hi], [ip + 1]
    add [0], 0, [rb + table]

    jz  [rb + table], handle_port_read_unmapped

    # Is there a read callback?
    mul [rb + port_lo], 2, [rb + tmp]
    add [rb + table], [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_port_read_unmapped

    # Call the read callback
    mul [rb + port_hi], 0x100, [rb - 1]
    add [rb + port_lo], [rb - 1], [rb - 1]
    arb -1
    call [rb + callback + 1]
    add [rb - 3], 0, [rb + value]

    jz  0, handle_port_read_done

handle_port_read_unmapped:
    # Input a constant for unmapped ports
    add 0xff, 0, [rb + value]

handle_port_read_done:
    arb 4
    ret 2
.ENDFRAME

##########
handle_port_write:
.FRAME port_lo, port_hi, value; table, callback, tmp
    arb -3

    # Is there any table at all?
    jz  [device_ports], handle_port_write_done

    # Is there a second level table?
    add [device_ports], [rb + port_hi], [ip + 1]
    add [0], 0, [rb + table]

    jz  [rb + table], handle_port_write_done

    # Is there a write callback?
    mul [rb + port_lo], 2, [rb + tmp]
    add [rb + table], [rb + tmp], [rb + tmp]
    add 1, [rb + tmp], [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_port_write_done

    # Call the write callback
    mul [rb + port_hi], 0x100, [rb - 1]
    add [rb + port_lo], [rb - 1], [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + callback + 2]

handle_port_write_done:
    arb 3
    ret 3
.ENDFRAME

##########
handle_memory_read:
.FRAME addr; value, read_through, record, start_addr, stop_addr, callback, tmp                      # returns value, read_through
    arb -7

    # Default is to read the value from main memory
    add 1, 0, [rb + read_through]

    # Is there any table at all?
    jz  [device_regions], handle_memory_read_done
    add [device_regions], 0, [rb + record]

handle_memory_read_loop:
    # Read stop address from current record
    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb + stop_addr]

    # Stop the loop once we reach a record with stop_addr == 0
    jz  [rb + stop_addr], handle_memory_read_done

    # Is address < stop_addr?
    lt  [rb + addr], [rb + stop_addr], [rb + tmp]
    jz  [rb + tmp], handle_memory_read_loop

    # Read start address from current record
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb + start_addr]

    # Is address >= start_addr?
    lt  [rb + addr], [rb + start_addr], [rb + tmp]
    jnz [rb + tmp], handle_memory_read_loop

    # Address is in this range, get the read callback
    add [rb + record], 3, [ip + 1]
    add [0], 0, [rb + callback]

    # Call the callback
    add [rb + addr], 0, [rb - 1]
    arb -1
    call [rb + callback + 1]
    add [rb - 3], 0, [rb + value]
    add [rb - 4], 0, [rb + read_through]

handle_memory_read_done:
    arb 7
    ret 1
.ENDFRAME

##########
handle_memory_write:
.FRAME addr, value; write_through, record, start_addr, stop_addr, callback, tmp                      # returns write_through
    arb -6

    # Default is to write the value to main memory
    add 1, 0, [rb + write_through]

    # Is there any table at all?
    jz  [device_regions], handle_memory_write_done
    add [device_regions], 0, [rb + record]

handle_memory_write_loop:
    # Read stop address from current record
    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb + stop_addr]

    # Stop the loop once we reach a record with stop_addr == 0
    jz  [rb + stop_addr], handle_memory_write_done

    # Is address < stop_addr?
    lt  [rb + addr], [rb + stop_addr], [rb + tmp]
    jz  [rb + tmp], handle_memory_write_loop

    # Read start address from current record
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb + start_addr]

    # Is address >= start_addr?
    lt  [rb + addr], [rb + start_addr], [rb + tmp]
    jnz [rb + tmp], handle_memory_write_loop

    # Address is in this range, get the write callback
    add [rb + record], 4, [ip + 1]
    add [0], 0, [rb + callback]

    # Call the callback
    add [rb + addr], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + callback + 1]
    add [rb - 4], 0, [rb + write_through]

handle_memory_write_done:
    arb 6
    ret 2
.ENDFRAME

.EOF
