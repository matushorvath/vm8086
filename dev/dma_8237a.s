.EXPORT init_dma_8237a
.EXPORT dma_receive_data

.EXPORT dma_disable_controller
.EXPORT dma_mask_ch2
.EXPORT dma_transfer_type_ch2
.EXPORT dma_mode_ch2
.EXPORT dma_count_ch2

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
# TODO .IMPORT report_error

# From cpu/state.s
.IMPORT mem

# From util/bits.s
.IMPORT bits

# TODO remove
.IMPORT print_num_2
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
.FRAME channel, src_addr, count; dst_addr, index, tmp
    arb -3

#    # TODO fdcm remove
#    out 'd'
#    out 'D'
#    out ' '

    # TODO range check channel

    # Check the DMA controller
    jnz [dma_disable_controller], dma_receive_data_drop

    add dma_mask_channels, [rb + channel], [ip + 1]
    jnz [dma_mask_channels], dma_receive_data_drop

    add dma_transfer_type_channels, [rb + channel], [ip + 1]
    eq  [0], 1, [rb + tmp]                                  # transfer type must be write (1)
    jz  [rb + tmp], dma_receive_data_drop

    # TODO support single/block/demand modes

    # Decrease the DMA counter
    add dma_count_channels, [rb + channel], [ip + 5]
    add dma_count_channels, [rb + channel], [ip + 3]
    add [0], [rb + count], [0]

    # Determine where should we write the data
    add dma_page_channels, [rb + channel], [ip + 1]
    mul [0], 0xffff, [rb + dst_addr]
    add dma_address_channels, [rb + channel], [ip + 1]
    add [0], [rb + dst_addr], [rb + dst_addr]
    add [mem], [rb + dst_addr], [rb + dst_addr]

#    # TODO fdcm
#    out 10
#    out 10
#    out 'X'
#    out 'X'
#    out 'X'
#    out 10
#
#    add [rb + src_addr], 0, [rb - 1]
#    arb -1
#    call print_num_16
#    out 10

    add 0, 0, [rb + index]

dma_receive_data_loop:
    # Move the data
    add [rb + src_addr], [rb + index], [ip + 5]
    # TODO handle dma_decrement_channels
    add [rb + dst_addr], [rb + index], [ip + 3]
    add [0], 0, [0]

#    # TODO fdcm remove
#    add [rb + src_addr], [rb + index], [ip + 1]
#    add [0], 0, [rb - 1]
#    arb -1
#    call print_num_16
#    out ' '

    # Increase index
    # TODO handle wraparound for dst_addr, it wraps around 0xffff and then adds the shifted page
    add [rb + index], 1, [rb + index]

    # Decrease count and loop
    add [rb + count], -1, [rb + count]
    jnz [rb + count], dma_receive_data_loop

    # TODO handle dma_auto_init_channels (remember originally set values, reset them after count goes to 0xffff)

dma_receive_data_drop:
    arb 3
    ret 3
.ENDFRAME

##########
dma_mode_write:
.FRAME addr, value; value_x8, channel, transfer_type, dma_mode, tmp
    arb -5

#    # TODO fdcm remove
#    out 'd'
#    out 'M'
#    add [rb + value], 0, [rb - 1]
#    arb -1
#    call print_num_2
#    out ' '

    # Set DMA mode
    mul [rb + value], 8, [rb + value_x8]

    # Read channel number from bits 0 and 1
    add bits + 1, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + channel]
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # Read transfer type from bits 2 and 3
    add bits + 3, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + transfer_type]
    add bits + 2, [rb + value_x8], [ip + 1]
    add [0], [rb + transfer_type], [rb + transfer_type]

    # Transfer type 0b11 is invalid
    eq  [rb + transfer_type], 0b11, [rb + tmp]
    jnz [rb + tmp], dma_mode_write_done

    # Read DMA mode from bits 6 and 7
    add bits + 7, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + dma_mode]
    add bits + 6, [rb + value_x8], [ip + 1]
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
    add bits + 4, [rb + value_x8], [ip + 1]
    add [0], 0, [rb + tmp]
    add dma_auto_init_channels, [rb + channel], [ip + 3]
    add [rb + tmp], 0, [0]

    # Read and save decrement mode
    add bits + 5, [rb + value_x8], [ip + 1]
    add [0], 0, [rb + tmp]
    add dma_decrement_channels, [rb + channel], [ip + 3]
    add [rb + tmp], 0, [0]

dma_mode_write_done:
    arb 5
    ret 2
.ENDFRAME

##########
dma_command_write:
.FRAME addr, value; value_x8
    arb -1

    # Only bit 3 is useful, it disables the DMA controller
    mul [rb + value], 8, [rb + value_x8]
    add bits + 3, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_disable_controller]

    arb 1
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
#    # TODO fdcm remove
#    out 'd'
#    out 'R'
#    out ' '

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
dma_flip_flop_reset_write:
.FRAME addr, value;
    # Set the flip-flop to access the low byte
    add 0, 0, [dma_flip_flop]
    ret 2
.ENDFRAME

##########
dma_single_channel_mask_write:
.FRAME addr, value; value_x8, channel, mask
    arb -3

    # Mask a single channel
    mul [rb + value], 8, [rb + value_x8]

    # Read channel number from bits 0 and 1
    add bits + 1, [rb + value_x8], [ip + 1]
    mul [0], 0b10, [rb + channel]
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], [rb + channel], [rb + channel]

    # Read mask/unmask value from bit 2
    add bits + 2, [rb + value_x8], [ip + 1]
    add [0], 0, [rb + mask]

    # Mask/unmask the channel
    add dma_mask_channels, [rb + channel], [ip + 3]
    add [rb + mask], 0, [0]

    arb 3
    ret 2
.ENDFRAME

##########
dma_multi_channel_mask_write:
.FRAME addr, value; value_x8
    arb -1

    # Mask a all channels
    mul [rb + value], 8, [rb + value_x8]

    # Set mask for individual channels
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch0]

    add bits + 1, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch1]

    add bits + 2, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch2]

    add bits + 3, [rb + value_x8], [ip + 1]
    add [0], 0, [dma_mask_ch3]

    arb 1
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

#    # TODO fdcm remove
#    out 'd'
#    out 'A'
#    out '2'
#    out '_'
#    add [rb + value], 0, [rb - 1]
#    arb -1
#    call print_num_16
#    out '_'

    # Clear the register if we are writing the lo byte
    mul [dma_address_ch2], [dma_flip_flop], [dma_address_ch2]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_address_ch2], [rb + value], [dma_address_ch2]
    eq  [dma_flip_flop], 0, [dma_flip_flop]

#    # TODO fdcm remove
#    add [dma_address_ch2], 0, [rb - 1]
#    arb -1
#    call print_num_16
#    out ' '

    arb 1
    ret 2
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

#    # TODO fdcm remove
#    out 'd'
#    out 'C'
#    out '2'
#    out '_'
#    add [rb + value], 0, [rb - 1]
#    arb -1
#    call print_num_16
#    out '_'

    # Clear the register if we are writing the lo byte
    mul [dma_count_ch2], [dma_flip_flop], [dma_count_ch2]

    # Shift the value left by 8 if we are writing the hi byte
    mul 0xff, [dma_flip_flop], [rb + tmp]
    add [rb + tmp], 1, [rb + tmp]
    mul [rb + value], [rb + tmp], [rb + value]

    # Add the value to the register
    add [dma_count_ch2], [rb + value], [dma_count_ch2]
    eq  [dma_flip_flop], 0, [dma_flip_flop]

#    # TODO fdcm remove
#    add [dma_count_ch2], 0, [rb - 1]
#    arb -1
#    call print_num_16
#    out ' '

    arb 1
    ret 2
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
#    # TODO fdcm remove
#    out 'd'
#    out 'P'
#    out '2'
#    out '_'
#    add [rb + value], 0, [rb - 1]
#    arb -1
#    call print_num_2
#    out ' '

    add [rb + value], 0, [dma_page_ch2]
    ret 2
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

.EOF
