.EXPORT register_region

.EXPORT read_memory_b
.EXPORT write_memory_b

# From state.s
.IMPORT mem

# From util/error.s
.IMPORT report_error

# From libxib.a
.IMPORT sbrk

##########
register_region:
.FRAME start_addr, stop_addr, read_callback, write_callback; curr_record, prev_record, new_record, curr_start_addr, prev_stop_addr, tmp
    arb -6

    # Store the regions in a linked list, ordered by start_addr

    add 0, 0, [rb + prev_record]
    add [device_regions], 0, [rb + curr_record]

.loop:
    jz  [rb + curr_record], .search_done

    # Loop while start address of current region is lower than the region we are adding
    add [rb + curr_record], 1, [ip + 1]
    add [0], 0, [rb + curr_start_addr]

    lt  [rb + curr_start_addr], [rb + start_addr], [rb + tmp]
    jz  [rb + tmp], .search_done

    # Next record
    add [rb + curr_record], 0, [rb + prev_record]
    add [rb + curr_record], 0, [ip + 1]
    add [0], 0, [rb + curr_record]

    jz  0, .loop

.search_done:
    # Check that the region we're adding does not overlap previous region
    jz  [rb + prev_record], .after_prev_check

    add [rb + prev_record], 2, [ip + 1]
    add [0], 0, [rb + prev_stop_addr]

    lt  [rb + start_addr], [rb + prev_stop_addr], [rb + tmp]
    jnz [rb + tmp], .overlap_error

.after_prev_check:
    # Check that the region we're adding does not overlap current region
    jz  [rb + curr_record], .after_curr_check

    lt  [rb + curr_start_addr], [rb + stop_addr], [rb + tmp]
    jnz [rb + tmp], .overlap_error

.after_curr_check:
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
    jnz [rb + prev_record], .link_prev

    # Otherwise link the root of the list
    add [rb + new_record], 0, [device_regions]
    jz  0, .link_next

.link_prev:
    add [rb + prev_record], 0, [ip + 3]
    add [rb + new_record], 0, [0]

.link_next:
    # Link the next record (which could be zero)
    add [rb + new_record], 0, [ip + 3]
    add [rb + curr_record], 0, [0]

    arb 6
    ret 4

.overlap_error:
    add .overlap_message, 0, [rb - 1]
    arb -1
    call report_error

.overlap_message:
    db  "Unable to register a memory region; the regions must not overlap", 0
.ENDFRAME

##########
read_memory_b:
.FRAME addr; value, record, callback, tmp                   # returns value
    arb -4

    # This function is hit very heavily and needs to be optimized as much as possible

    add [device_regions], 0, [rb + record]

.loop:
    jz  [rb + record], .no_handler

    # Loop while the stop address of current region is lower or equal than the search address
    add [rb + record], 2, [ip + 2]
    lt  [rb + addr], [0], [rb + tmp]
    jnz [rb + tmp], .found

    # Next record
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb + record]

    jz  0, .loop

.found:
    # Check if start address of the current region is lower or equal then the search address
    add [rb + record], 1, [ip + 2]
    lt  [rb + addr], [0], [rb + tmp]
    jnz [rb + tmp], .no_handler

    # Address is in this region, get the read callback
    add [rb + record], 3, [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], .no_handler

    # Call the callback
    add [rb + addr], 0, [rb - 1]
    arb -1
    call [rb + callback + 1]
    add [rb - 3], 0, [rb + value]

    # Should we read the value from main memory anyway?
    jz  [rb - 4], .done

.no_handler:
    # Read the value from main memory
    add [mem], [rb + addr], [ip + 1]
    add [0], 0, [rb + value]

.done:
    arb 4
    ret 1
.ENDFRAME

##########
write_memory_b:
.FRAME addr, value; record, callback, tmp
    arb -3

    # This function is hit very heavily and needs to be optimized as much as possible

    add [device_regions], 0, [rb + record]

.loop:
    jz  [rb + record], .no_handler

    # Loop while the stop address of current region is lower or equal than the search address
    add [rb + record], 2, [ip + 2]
    lt  [rb + addr], [0], [rb + tmp]
    jnz [rb + tmp], .found

    # Next record
    add [rb + record], 0, [ip + 1]
    add [0], 0, [rb + record]

    jz  0, .loop

.found:
    # Check if start address of the current region is lower or equal then the search address
    add [rb + record], 1, [ip + 2]
    lt  [rb + addr], [0], [rb + tmp]
    jnz [rb + tmp], .no_handler

    # Address is in this region, get the write callback
    add [rb + record], 4, [ip + 1]
    add [0], 0, [rb + callback]

    jz  [rb + callback], .no_handler

    # Call the callback
    add [rb + addr], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call [rb + callback + 2]

    # Should we read the value from main memory anyway?
    jz  [rb - 4], .done

.no_handler:
    # Write the value to main memory
    add [mem], [rb + addr], [ip + 3]
    add [rb + value], 0, [0]

.done:
    arb 3
    ret 2
.ENDFRAME

##########
# Data structures:

# Linked list of memory regions records, each 5 bytes
# Regions must not overlap, must be sorted by start_addr
# device_region = { next_record, start_addr, stop_addr, read_callback, write_callback }
device_regions:
    db  0

.EOF
