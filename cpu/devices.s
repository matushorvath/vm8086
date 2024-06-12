.EXPORT register_port
.EXPORT register_ports
.EXPORT register_region

.EXPORT handle_port_read
.EXPORT handle_port_write
.EXPORT handle_memory_read
.EXPORT handle_memory_write

# From brk.s
.IMPORT sbrk

# From util/error.s
.IMPORT report_error

# From libxib.a
.IMPORT zeromem

##########
register_ports:
.FRAME ports; record, tmp
    arb -2

    # Expect an array of 4 byte records (port_lo, port_hi, read_callback, write_callback)
    # terminated by a record of four -1s.

    add [rb + ports], 0, [rb + record]

register_ports_loop:
    # Load next record and register the port
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb - 1]

    eq  [rb - 1], -1, [rb + tmp]
    jnz [rb + tmp], register_ports_done

    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb - 2]
    add [rb + record], 2, [ip + 1]
    add [0], 0, [rb - 3]
    add [rb + record], 3, [ip + 1]
    add [0], 0, [rb - 4]

    arb -4
    call register_port

    add [rb + record], 4, [rb + record]

    jz  0, register_ports_loop

register_ports_done:
    arb 2
    ret 1
.ENDFRAME

##########
register_port:
.FRAME port_lo, port_hi, read_callback, write_callback; table, ptr
    arb -2

    # Is there any table at all?
    jnz [device_ports], register_port_have_first_table

    # No, create one
    add 0x100, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [device_ports]

    add [device_ports], 0, [rb - 1]
    add 0x100, 0, [rb - 2]
    arb -2
    call zeromem

register_port_have_first_table:
    # Is there a second level table?
    add [device_ports], [rb + port_hi], [ip + 1]
    add [0], 0, [rb + table]

    jnz [rb + table], register_port_have_second_table

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

register_port_have_second_table:
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
register_region:
.FRAME start_addr, stop_addr, read_callback, write_callback; curr_record, prev_record, new_record, curr_start_addr, prev_stop_addr, tmp
    arb -6

    # Store the regions in a linked list, ordered by start_addr

    add 0, 0, [rb + prev_record]
    add [device_regions], 0, [rb + curr_record]

register_region_loop:
    jz  [rb + curr_record], register_region_search_done

    # Loop while start address of current region is lower than the region we are adding
    add [rb + curr_record], 1, [ip + 1]
    add [0], 0, [rb + curr_start_addr]

    lt  [rb + curr_start_addr], [rb + start_addr], [rb + tmp]
    jz  [rb + tmp], register_region_search_done

    # Next record
    add [rb + curr_record], 0, [rb + prev_record]
    add [rb + curr_record], 0, [ip + 1]
    add [0], 0, [rb + curr_record]

    jz  0, register_region_loop

register_region_search_done:
    # Check that the region we're adding does not overlap previous region
    jz  [rb + prev_record], register_region_after_prev_check

    add [rb + prev_record], 2, [ip + 1]
    add [0], 0, [rb + prev_stop_addr]

    lt  [rb + start_addr], [rb + prev_stop_addr], [rb + tmp]
    jnz [rb + tmp], register_region_overlap_error

register_region_after_prev_check:
    # Check that the region we're adding does not overlap current region
    jz  [rb + curr_record], register_region_after_curr_check

    lt  [rb + curr_start_addr], [rb + stop_addr], [rb + tmp]
    jnz [rb + tmp], register_region_overlap_error

register_region_after_curr_check:
    # Create and fill a new region record
    add 5, 0, [rb - 1]
    arb -1
    call sbrk
    add [rb - 3], 0, [rb + new_record]

    add [rb + new_record], 1, [ip + 3]
    add [rb + start_addr], 0, [0]
    add [rb + new_record], 2, [ip + 3]
    add [rb + stop_addr], 0, [0]
    add [rb + new_record], 3, [ip + 3]
    add [rb + read_callback], 0, [0]
    add [rb + new_record], 4, [ip + 3]
    add [rb + write_callback], 0, [0]

    # If there is a previous record, link it
    jnz [rb + prev_record], register_region_link_prev

    # Otherwise link the root of the list
    add [rb + new_record], 0, [device_regions]
    jz  0, register_region_link_next

register_region_link_prev:
    add [rb + prev_record], 0, [ip + 3]
    add [rb + new_record], 0, [0]

register_region_link_next:
    # Link the next record (which could be zero)
    add [rb + new_record], 0, [ip + 3]
    add [rb + curr_record], 0, [0]

    arb 6
    ret 4

register_region_overlap_error:
    add register_region_overlap_message, 0, [rb - 1]
    arb -1
    call report_error

register_region_overlap_message:
    db  "Unable to register a memory region; ", "the regions must not overlap", 0
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
    jz  [rb + record], handle_memory_read_done

    # Loop while the stop address of current region is lower or equal than the search address
    add [rb + record], 2, [ip + 1]
    add [0], 0, [rb + stop_addr]

    lt  [rb + addr], [rb + stop_addr], [rb + tmp]
    jnz [rb + tmp], handle_memory_read_found

    # Next record
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb + record]

    jz  0, handle_memory_read_loop

handle_memory_read_found:
    # Check if start address of the current region is lower or equal then the search address
    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb + start_addr]

    lt  [rb + addr], [rb + start_addr], [rb + tmp]
    jnz [rb + tmp], handle_memory_read_done

    # Address is in this region, get the read callback
    add [rb + record], 3, [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_memory_read_done

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
.FRAME addr, value; write_through, record, start_addr, stop_addr, callback, tmp                     # returns write_through
    arb -6

    # Default is to write the value to main memory
    add 1, 0, [rb + write_through]

    # Is there any table at all?
    jz  [device_regions], handle_memory_write_done
    add [device_regions], 0, [rb + record]

handle_memory_write_loop:
    jz  [rb + record], handle_memory_write_done

    # Loop while the stop address of current region is lower or equal than the search address
    add [rb + record], 2, [ip + 1]
    add [0], 0, [rb + stop_addr]

    lt  [rb + addr], [rb + stop_addr], [rb + tmp]
    jnz [rb + tmp], handle_memory_write_found

    # Next record
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb + record]

    jz  0, handle_memory_write_loop

handle_memory_write_found:
    # Check if start address of the current region is lower or equal then the search address
    add [rb + record], 1, [ip + 1]
    add [0], 0, [rb + start_addr]

    lt  [rb + addr], [rb + start_addr], [rb + tmp]
    jnz [rb + tmp], handle_memory_write_done

    # Address is in this range, get the write callback
    add [rb + record], 4, [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], handle_memory_write_done

    # Call the callback
    add [rb + addr], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + callback + 2]
    add [rb - 4], 0, [rb + write_through]

handle_memory_write_done:
    arb 6
    ret 2
.ENDFRAME

##########
# Data structures:

# Pointer to a two level table of 256 * 256 records, each 2 bytes
# device_ports_level_1 = { device_ports_level_2 }[256]
# device_ports_level_2 = { read_callback, write_callback }[256]
device_ports:
    db  0

# Linked list of memory regions records, each 5 bytes
# Regions must not overlap, must be sorted by start_addr
# device_region = { next_record, start_addr, stop_addr, read_callback, write_callback }
device_regions:
    db  0

.EOF
