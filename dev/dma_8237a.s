.EXPORT init_dma_8237a
.EXPORT dma_receive_data

.EXPORT dma_disable_controller
.EXPORT dma_mask_ch2
.EXPORT dma_transfer_type_ch2
.EXPORT dma_mode_ch2
.EXPORT dma_count_ch2

# From the config file
.IMPORT config_log_fdc

# From cpu/devices.s
.IMPORT register_ports

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bit_0
.IMPORT bit_1
.IMPORT bit_2
.IMPORT bit_3
.IMPORT bit_4
.IMPORT bit_5
.IMPORT bit_6
.IMPORT bit_7

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_2_b
.IMPORT print_num_16

##########
dma_ports:
    db  0x02, 0x00, 0, dma_address_ch1_write                # start address register channel 1
    db  0x03, 0x00, 0, dma_count_ch1_write                  # count register channel 1
    db  0x04, 0x00, 0, dma_address_ch2_write                # start address register channel 2
    db  0x05, 0x00, 0, dma_count_ch2_write                  # count register channel 2
    db  0x06, 0x00, 0, dma_address_ch3_write                # start address register channel 3
    db  0x07, 0x00, 0, dma_count_ch3_write                  # count register channel 3

    db  0x08, 0x00, dma_status_read, dma_command_write      # status register, command register
    db  0x0a, 0x00, 0, dma_single_channel_mask_write        # single channel mask register
    db  0x0b, 0x00, 0, dma_mode_write                       # mode register
    db  0x0c, 0x00, 0, dma_flip_flop_reset_write            # flip-flop reset register
    db  0x0d, 0x00, 0, dma_master_reset_write               # master reset register
    db  0x0e, 0x00, 0, dma_mask_reset_write                 # mask reset register
    db  0x0f, 0x00, 0, dma_multi_channel_mask_write         # multichannel mask register

    db  0x81, 0x00, dma_page_ch2_read, dma_page_ch2_write   # channel 2 page address register
    db  0x82, 0x00, dma_page_ch3_read, dma_page_ch3_write   # channel 3 page address register
    db  0x83, 0x00, dma_page_ch1_read, dma_page_ch1_write   # channel 1 page address register

    db  -1, -1, -1, -1

# Following ports are not required:
#  - 0x00 start adddress register channel 0
#  - 0x01 count register channel 0
#  - 0x09 request register
#  - 0x0d intermediate register (read)
#  - 0x87 channel 0 page address register

##########
init_dma_8237a:
.FRAME
    # Register I/O ports
    add dma_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
dma_receive_data:
.FRAME channel, src_addr, count; dst_addr, dst_delta, index, tmp
    arb -4

    # Floppy controller logging
    jz  [config_log_fdc], dma_receive_data_after_log_fdc
    eq  [rb + channel], 0x02, [rb + tmp]
    jz  [rb + tmp], dma_receive_data_after_log_fdc

    add [rb + count], 0, [rb - 1]
    arb -1
    call dma_receive_data_log_fdc

dma_receive_data_after_log_fdc:
    # Check the DMA controller
    jnz [dma_disable_controller], dma_receive_data_disabled

    add dma_mask_channels, [rb + channel], [ip + 1]
    jnz [dma_mask_channels], dma_receive_data_disabled

    add dma_transfer_type_channels, [rb + channel], [ip + 1]
    eq  [0], 1, [rb + tmp]                                  # transfer type must be write (1)
    jz  [rb + tmp], dma_receive_data_disabled

    # TODO support single/block/demand modes

    # Decrement the destination address if requested
    add dma_decrement_channels, [rb + channel], [ip + 1]
    mul [0], -2, [rb + dst_delta]
    add [rb + dst_delta], 1, [rb + dst_delta]

    # Determine where we should write the data
    add dma_page_channels, [rb + channel], [ip + 1]
    mul [0], 0x10000, [rb + dst_addr]
    add dma_address_channels, [rb + channel], [ip + 1]
    add [0], [rb + dst_addr], [rb + dst_addr]
    add [mem], [rb + dst_addr], [rb + dst_addr]

    # Calculate how much data to move, count = min(count, dma_count_*+1)
    add dma_count_channels, [rb + channel], [ip + 1]
    add [0], 1, [rb + tmp]
    lt  [rb + tmp], [rb + count], [rb + tmp]
    jz  [rb + tmp], dma_receive_data_move

    add dma_count_channels, [rb + channel], [ip + 1]
    add [0], 1, [rb + count]

dma_receive_data_move:
    add [rb + count], 0, [rb + index]

dma_receive_data_loop:
    # Move the data
    add [rb + src_addr], 0, [ip + 5]
    add [rb + dst_addr], 0, [ip + 3]
    add [0], 0, [0]

    # Increment source address, increment/decrement destination address
    # TODO handle wraparound for dst_addr, it wraps around 0x10000 and then adds the page
    add [rb + src_addr], 1, [rb + src_addr]
    add [rb + dst_addr], [rb + dst_delta], [rb + dst_addr]

    # Decrease index and loop
    add [rb + index], -1, [rb + index]
    jnz [rb + index], dma_receive_data_loop

    # Update the DMA counter, decrease it by count
    mul [rb + count], -1, [rb + tmp]
    add dma_count_channels, [rb + channel], [ip + 5]
    add dma_count_channels, [rb + channel], [ip + 3]
    add [0], [rb + tmp], [0]

    # Update destination address, increase/decrease it by count
    # TODO wraparound the address, make sure it stays between 0x0000 and 0x10000
    mul [rb + count], [rb + dst_delta], [rb + tmp]
    add dma_address_channels, [rb + channel], [ip + 5]
    add dma_address_channels, [rb + channel], [ip + 3]
    add [0], [rb + tmp], [0]

    # TODO handle dma_auto_init_channels (remember originally set values, reset them after dma_count_ch* goes to -1)

dma_receive_data_disabled:
    arb 4
    ret 3
.ENDFRAME

##########
dma_receive_data_log_fdc:
.FRAME count;
    call log_start

    add dma_receive_data_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + count], 0, [rb - 1]
    arb -1
    call print_num

    out 10
    ret 1

dma_receive_data_log_fdc_start:
    db  "dma ch02, receive data, count ", 0
.ENDFRAME

##########
dma_mode_write:
.FRAME addr, value; channel, transfer_type, dma_mode, tmp
    arb -4

    # Set DMA mode

    # Floppy controller logging
    jz  [config_log_fdc], dma_mode_write_after_log_fdc
    eq  [rb + channel], 0x02, [rb + tmp]
    jz  [rb + tmp], dma_mode_write_after_log_fdc

    add [rb + value], 0, [rb - 1]
    arb -1
    call dma_mode_write_log_fdc

dma_mode_write_after_log_fdc:
    # Read channel number from bits 0 and 1
    add bit_1, [rb + value], [ip + 1]
    mul [0], 0b10, [rb + channel]
    add bit_0, [rb + value], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # Read transfer type from bits 2 and 3
    add bit_3, [rb + value], [ip + 1]
    mul [0], 0b10, [rb + transfer_type]
    add bit_2, [rb + value], [ip + 1]
    add [0], [rb + transfer_type], [rb + transfer_type]

    # Transfer type 0b11 is invalid
    eq  [rb + transfer_type], 0b11, [rb + tmp]
    jnz [rb + tmp], dma_mode_write_done

    # Read DMA mode from bits 6 and 7
    add bit_7, [rb + value], [ip + 1]
    mul [0], 0b10, [rb + dma_mode]
    add bit_6, [rb + value], [ip + 1]
    add [0], [rb + dma_mode], [rb + dma_mode]

    # DMA mode 0b11 (cascade) is invalid
    eq  [rb + dma_mode], 0b11, [rb + tmp]
    jnz [rb + tmp], dma_mode_write_done

    # Save transfer type
    add dma_transfer_type_channels, [rb + channel], [ip + 3]
    add [rb + transfer_type], 0, [0]

    # Save DMA mode
    add dma_mode_channels, [rb + channel], [ip + 3]
    add [rb + dma_mode], 0, [0]

    # Read and save auto init mode
    add bit_4, [rb + value], [ip + 1]
    add [0], 0, [rb + tmp]
    add dma_auto_init_channels, [rb + channel], [ip + 3]
    add [rb + tmp], 0, [0]

    # Read and save decrement mode
    add bit_5, [rb + value], [ip + 1]
    add [0], 0, [rb + tmp]
    add dma_decrement_channels, [rb + channel], [ip + 3]
    add [rb + tmp], 0, [0]

dma_mode_write_done:
    arb 4
    ret 2
.ENDFRAME

##########
dma_mode_write_log_fdc:
.FRAME value;
    call log_start

    add dma_mode_write_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_2_b

    out 10
    ret 1

dma_mode_write_log_fdc_start:
    db  "dma ch02, receive data, mode ", 0
.ENDFRAME

##########
dma_command_write:
.FRAME addr, value;
    # Only bit 3 is useful, it disables the DMA controller
    add bit_3, [rb + value], [ip + 1]
    add [0], 0, [dma_disable_controller]

    ret 2
.ENDFRAME

##########
dma_status_read:
.FRAME addr; value
    arb -1
    # TODO
    arb 1
    ret 1
.ENDFRAME

##########
dma_master_reset_write:
.FRAME addr, value;
    # Floppy controller logging
    jz  [config_log_fdc], dma_master_reset_write_after_log_fdc
    call dma_master_reset_write_log_fdc

dma_master_reset_write_after_log_fdc:
    # Set the flip-flop to access the low byte
    add 0, 0, [dma_flip_flop]

    # TODO clear status

    # Set all channel masks to 1
    add 1, 0, [dma_mask_ch0]
    add 1, 0, [dma_mask_ch1]
    add 1, 0, [dma_mask_ch2]
    add 1, 0, [dma_mask_ch3]

    ret 2
.ENDFRAME

##########
dma_master_reset_write_log_fdc:
.FRAME
    call log_start

    add dma_master_reset_write_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    out 10
    ret 0

dma_master_reset_write_log_fdc_start:
    db  "dma master reset", 0
.ENDFRAME

##########
dma_flip_flop_reset_write:
.FRAME addr, value;
    # Set the flip-flop to access the low byte
    add 0, 0, [dma_flip_flop]
    ret 2
.ENDFRAME

##########
dma_single_channel_mask_write:
.FRAME addr, value; channel, mask
    arb -2

    # Mask a single channel

    # Read channel number from bits 0 and 1
    add bit_1, [rb + value], [ip + 1]
    mul [0], 0b10, [rb + channel]
    add bit_0, [rb + value], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # Read mask/unmask value from bit 2
    add bit_2, [rb + value], [ip + 1]
    add [0], 0, [rb + mask]

    # Mask/unmask the channel
    add dma_mask_channels, [rb + channel], [ip + 3]
    add [rb + mask], 0, [0]

    arb 2
    ret 2
.ENDFRAME

##########
dma_multi_channel_mask_write:
.FRAME addr, value;
    # Mask a all channels
    add bit_0, [rb + value], [ip + 1]
    add [0], 0, [dma_mask_ch0]

    add bit_1, [rb + value], [ip + 1]
    add [0], 0, [dma_mask_ch1]

    add bit_2, [rb + value], [ip + 1]
    add [0], 0, [dma_mask_ch2]

    add bit_3, [rb + value], [ip + 1]
    add [0], 0, [dma_mask_ch3]

    ret 2
.ENDFRAME

##########
dma_mask_reset_write:
.FRAME addr, value;
    # Reset all channel masks to 0
    add 0, 0, [dma_mask_ch0]
    add 0, 0, [dma_mask_ch1]
    add 0, 0, [dma_mask_ch2]
    add 0, 0, [dma_mask_ch3]

    ret 2
.ENDFRAME

##########
dma_address_ch1_write:
.FRAME addr, value; tmp
    arb -1

    # Clear the register if we are writing the lo byte
    mul [dma_address_ch1], [dma_flip_flop], [dma_address_ch1]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_address_ch1], [rb + value], [dma_address_ch1]
    eq  [dma_flip_flop], 0, [dma_flip_flop]

    arb 1
    ret 2
.ENDFRAME

##########
dma_address_ch2_write:
.FRAME addr, value; tmp
    arb -1

    # Clear the register if we are writing the lo byte
    mul [dma_address_ch2], [dma_flip_flop], [dma_address_ch2]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_address_ch2], [rb + value], [dma_address_ch2]

    # Floppy controller logging
    jz  [config_log_fdc], dma_address_ch2_write_after_log_fdc
    call dma_address_ch2_write_log_fdc

dma_address_ch2_write_after_log_fdc:
    eq  [dma_flip_flop], 0, [dma_flip_flop]

    arb 1
    ret 2
.ENDFRAME

##########
dma_address_ch2_write_log_fdc:
.FRAME
    call log_start

    add dma_address_ch2_write_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add dma_flip_flop_values, [dma_flip_flop], [ip + 1]
    out [0]
    out ' '

    add [dma_address_ch2], 0, [rb - 1]
    arb -1
    call print_num_16

    out 10
    ret 0

dma_address_ch2_write_log_fdc_start:
    db  "dma ch02, write address 0x", 0
.ENDFRAME

##########
dma_address_ch3_write:
.FRAME addr, value; tmp
    arb -1

    # Clear the register if we are writing the lo byte
    mul [dma_address_ch3], [dma_flip_flop], [dma_address_ch3]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_address_ch3], [rb + value], [dma_address_ch3]
    eq  [dma_flip_flop], 0, [dma_flip_flop]

    arb 1
    ret 2
.ENDFRAME

##########
dma_count_ch1_write:
.FRAME addr, value; tmp
    arb -1

    # Clear the register if we are writing the lo byte
    mul [dma_count_ch1], [dma_flip_flop], [dma_count_ch1]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_count_ch1], [rb + value], [dma_count_ch1]
    eq  [dma_flip_flop], 0, [dma_flip_flop]

    arb 1
    ret 2
.ENDFRAME

##########
dma_count_ch2_write:
.FRAME addr, value; tmp
    arb -1

    # Clear the register if we are writing the lo byte
    mul [dma_count_ch2], [dma_flip_flop], [dma_count_ch2]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_count_ch2], [rb + value], [dma_count_ch2]

    # Floppy controller logging
    jz  [config_log_fdc], dma_count_ch2_write_after_log_fdc
    call dma_count_ch2_write_log_fdc

dma_count_ch2_write_after_log_fdc:
    eq  [dma_flip_flop], 0, [dma_flip_flop]

    arb 1
    ret 2
.ENDFRAME

##########
dma_count_ch2_write_log_fdc:
.FRAME
    call log_start

    add dma_count_ch2_write_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add dma_flip_flop_values, [dma_flip_flop], [ip + 1]
    out [0]
    out ' '

    add [dma_count_ch2], 0, [rb - 1]
    arb -1
    call print_num

    out 10
    ret 0

dma_count_ch2_write_log_fdc_start:
    db  "dma ch02, write count ", 0
.ENDFRAME

##########
dma_count_ch3_write:
.FRAME addr, value; tmp
    arb -1

    # Clear the register if we are writing the lo byte
    mul [dma_count_ch3], [dma_flip_flop], [dma_count_ch3]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_count_ch3], [rb + value], [dma_count_ch3]
    eq  [dma_flip_flop], 0, [dma_flip_flop]

    arb 1
    ret 2
.ENDFRAME

##########
dma_page_ch1_read:
.FRAME addr; value
    arb -1

    add [dma_page_ch1], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch2_read:
.FRAME addr; value
    arb -1

    add [dma_page_ch2], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch3_read:
.FRAME addr; value
    arb -1

    add [dma_page_ch3], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
dma_page_ch1_write:
.FRAME addr, value;
    add [rb + value], 0, [dma_page_ch1]
    ret 2
.ENDFRAME

##########
dma_page_ch2_write:
.FRAME addr, value;
    # Floppy controller logging
    jz  [config_log_fdc], dma_page_ch2_write_after_log_fdc
    call dma_page_ch2_write_log_fdc

dma_page_ch2_write_after_log_fdc:
    add [rb + value], 0, [dma_page_ch2]

    ret 2
.ENDFRAME

##########
dma_page_ch2_write_log_fdc:
.FRAME
    call log_start

    add dma_page_ch2_write_log_fdc_start, 0, [rb - 1]
    arb -1
    call print_str

    add [dma_page_ch2], 0, [rb - 1]
    arb -1
    call print_num_16

    out 10
    ret 0

dma_page_ch2_write_log_fdc_start:
    db  "dma ch02, write page 0x", 0
.ENDFRAME

##########
dma_page_ch3_write:
.FRAME addr, value;
    add [rb + value], 0, [dma_page_ch3]
    ret 2
.ENDFRAME

##########
dma_disable_controller:
    db  0

dma_flip_flop:
    db  0

dma_mask_channels:
dma_mask_ch0:
    db  1
dma_mask_ch1:
    db  1
dma_mask_ch2:
    db  1
dma_mask_ch3:
    db  1

dma_transfer_type_channels:
dma_transfer_type_ch0:
    db  0
dma_transfer_type_ch1:
    db  0
dma_transfer_type_ch2:
    db  0
dma_transfer_type_ch3:
    db  0

dma_mode_channels:
dma_mode_ch0:
    db  0
dma_mode_ch1:
    db  0
dma_mode_ch2:
    db  0
dma_mode_ch3:
    db  0

dma_auto_init_channels:
dma_auto_init_ch0:
    db  0
dma_auto_init_ch1:
    db  0
dma_auto_init_ch2:
    db  0
dma_auto_init_ch3:
    db  0

dma_decrement_channels:
dma_decrement_ch0:
    db  0
dma_decrement_ch1:
    db  0
dma_decrement_ch2:
    db  0
dma_decrement_ch3:
    db  0

dma_address_channels:
dma_address_ch0:
    db  0
dma_address_ch1:
    db  0
dma_address_ch2:
    db  0
dma_address_ch3:
    db  0

dma_count_channels:
dma_count_ch0:
    db  0
dma_count_ch1:
    db  0
dma_count_ch2:
    db  0
dma_count_ch3:
    db  0

dma_page_channels:
dma_page_ch0:
    db  0
dma_page_ch1:
    db  0
dma_page_ch2:
    db  0
dma_page_ch3:
    db  0

# Strings used for logging the flip-flop value
dma_flip_flop_values:
    db  'L'
    db  'H'

.EOF
