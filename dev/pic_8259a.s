.EXPORT init_pic_8259a

# From the config file
.IMPORT config_log_pic

# From cpu/devices.s
.IMPORT register_ports

# From cpu/error.s
.IMPORT report_error

# From util/bits.s
.IMPORT bits

# From util/shr.s
.IMPORT shr

# From libxib.a
.IMPORT print_str
.IMPORT print_num_16_b

##########
pic_ports:
    db  0x20, 0x00, pic_status_read, pic_command_write      # Command/Status
    db  0x21, 0x00, pic_data_read, pic_data_write           # Data

    db  -1, -1, -1, -1

##########
init_pic_8259a:
.FRAME
    # Register I/O ports
    add pic_ports, 0, [rb - 1]
    arb -1
    call register_ports

    ret 0
.ENDFRAME

##########
pic_command_write:
.FRAME addr, value; value_x8, tmp
    arb -2

    # PIC logging
    jz  [config_log_pic], pic_command_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call pic_command_write_log

pic_command_write_after_log:
    mul [rb + value], 8, [rb + value_x8]

    # If bit 4 is 1, this is ICW1
    add bits + 4, [rb + value_x8], [ip + 1]
    jnz [0], pic_command_write_icw1

    # Bit 4 is 0; if bit 3 is 0, this is OCW2
    add bits + 3, [rb + value_x8], [ip + 1]
    jz  [0], pic_command_write_ocw2

    # Bit 3 is 1, this is OCW3
    jz  0, pic_command_write_ocw3

pic_command_write_icw1:
    # Receive ICW1

    # ICW4 is always required, since we only support the 8086/8088 mode
    add bits + 0, [rb + value_x8], [ip + 1]
    jz  [0], pic_command_write_invalid_icw1

    # No support for cascade mode, since there is just one PIC
    add bits + 1, [rb + value_x8], [ip + 1]
    jz  [0], pic_command_write_invalid_icw1

    # Only support edge triggered mode
    add bits + 3, [rb + value_x8], [ip + 1]
    jnz [0], pic_command_write_invalid_icw1

    # Clear the interrupt mask register
    add 0, 0, [pic_mask_irq0]
    add 0, 0, [pic_mask_irq1]
    add 0, 0, [pic_mask_irq2]
    add 0, 0, [pic_mask_irq3]
    add 0, 0, [pic_mask_irq4]
    add 0, 0, [pic_mask_irq5]
    add 0, 0, [pic_mask_irq6]
    add 0, 0, [pic_mask_irq7]

    # Set read register to read interrupt request
    add 0, 0, [pic_read_in_service]

    # Set up next state
    add S_EXPECT_ICW2, 0, [pic_state]
    jz  0, pic_command_write_done

pic_command_write_ocw2:
    # Receive OCW2

    # Decide what to do based on top 3 bits
    add shr + 5, [rb + value_x8], [ip + 1]
    add [0], pic_command_write_ocw2_table, [ip + 2]
    jz  0, [0]

pic_command_write_ocw2_table:
    db  pic_command_write_ocw2_not_supported
    db  pic_command_write_ocw2_non_specific_eoi
    db  pic_command_write_ocw2_nop
    db  pic_command_write_ocw2_not_supported
    db  pic_command_write_ocw2_not_supported
    db  pic_command_write_ocw2_not_supported
    db  pic_command_write_ocw2_not_supported
    db  pic_command_write_ocw2_not_supported

pic_command_write_ocw2_nop:
    # No operation
    jz  0, pic_command_write_done

pic_command_write_ocw2_not_supported:
    # Unsupported operation
    jz  0, pic_command_write_invalid_ocw2

pic_command_write_ocw2_non_specific_eoi:
    # Non-specific end of interrupt
    # TODO
    jz  0, pic_command_write_done

pic_command_write_ocw3:
    # Receive OCW3

    # Should we set the "read register" value?
    add bits + 1, [rb + value_x8], [ip + 1]
    jz  [0], pic_command_write_ocw3_after_rr

    # Yes, set the "read register" value
    add bits + 0, [rb + value_x8], [ip + 1]
    add [0], 0, [pic_read_in_service]

pic_command_write_ocw3_after_rr:
    # Should we set the "special mask mode" value?
    add bits + 6, [rb + value_x8], [ip + 1]
    jz  [0], pic_command_write_ocw3_after_smm

    # Yes, but we only support special mask mode off
    add bits + 5, [rb + value_x8], [ip + 1]
    jnz [0], pic_command_write_invalid_ocw3

pic_command_write_ocw3_after_smm:
    # Poll mode is not supported
    add bits + 2, [rb + value_x8], [ip + 1]
    jnz [0], pic_command_write_invalid_ocw3

pic_command_write_done:
    arb 2
    ret 2

pic_command_write_invalid_icw1:
    add pic_command_write_invalid_icw1_message, 0, [rb - 1]
    arb -1
    call report_error

pic_command_write_invalid_icw1_message:
    db  "PIC: invalid or unsupported ICW1 value", 0

pic_command_write_invalid_ocw2:
    add pic_command_write_invalid_ocw2_message, 0, [rb - 1]
    arb -1
    call report_error

pic_command_write_invalid_ocw2_message:
    db  "PIC: invalid or unsupported OCW2 value", 0

pic_command_write_invalid_ocw3:
    add pic_command_write_invalid_ocw3_message, 0, [rb - 1]
    arb -1
    call report_error

pic_command_write_invalid_ocw3_message:
    db  "PIC: invalid or unsupported OCW3 value", 0
.ENDFRAME

##########
pic_data_write:
.FRAME addr, value; value_x8, tmp
    arb -2

    # PIC logging
    jz  [config_log_pic], pic_data_write_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call pic_data_write_log

pic_data_write_after_log:
    mul [rb + value], 8, [rb + value_x8]

    # Continue based on PIC state
    add pic_data_write_table, [pic_state], [ip + 2]
    jz  0, [0]

pic_data_write_table:
    db  pic_data_write_default          # S_DEFAULT
    db  pic_data_write_expect_icw2      # S_EXPECT_ICW2
    db  pic_data_write_expect_icw4      # S_EXPECT_ICW4

pic_data_write_default:
    # Receive OCW1

    # Save individual bits of the interrupt mask register (IMR)
    lt  0b01111111, [rb + value], [pic_mask_irq0]
    mul [pic_mask_irq0], -0b10000000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00111111, [rb + value], [pic_mask_irq1]
    mul [pic_mask_irq1], -0b01000000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00011111, [rb + value], [pic_mask_irq2]
    mul [pic_mask_irq2], -0b00100000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00001111, [rb + value], [pic_mask_irq3]
    mul [pic_mask_irq3], -0b00010000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00000111, [rb + value], [pic_mask_irq4]
    mul [pic_mask_irq4], -0b00001000, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00000011, [rb + value], [pic_mask_irq5]
    mul [pic_mask_irq5], -0b00000100, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00000001, [rb + value], [pic_mask_irq6]
    mul [pic_mask_irq6], -0b00000010, [rb + tmp]
    add [rb + value], [rb + tmp], [rb + value]

    lt  0b00000000, [rb + value], [pic_mask_irq7]

    jz  0, pic_data_write_done

pic_data_write_expect_icw2:
    # Receive ICW2

    # Top 5 bits are the interrupt vector offset
    # We only support the offset of 8, which maps IRQ0-7 to interrupts 8-15
    add shr + 3, [rb + value_x8], [ip + 1]
    eq  [0], 0b00001, [rb + tmp]
    jz  [rb + tmp], pic_data_write_invalid_icw2

    # Set up next state
    add S_EXPECT_ICW4, 0, [pic_state]
    jz  0, pic_data_write_done

pic_data_write_expect_icw4:
    # Receive ICW4

    # We only support the 8086/8088 mode
    add bits + 0, [rb + value_x8], [ip + 1]
    jz  [0], pic_data_write_invalid_icw3

    # No support for auto end of interrupt
    add bits + 1, [rb + value_x8], [ip + 1]
    jnz [0], pic_data_write_invalid_icw3

    # No support for special fully nested mode
    add bits + 4, [rb + value_x8], [ip + 1]
    jnz [0], pic_data_write_invalid_icw3

    # Set up next state
    add S_DEFAULT, 0, [pic_state]

pic_data_write_done:
    arb 2
    ret 2

pic_data_write_invalid_icw2:
    add pic_data_write_invalid_icw2_message, 0, [rb - 1]
    arb -1
    call report_error

pic_data_write_invalid_icw2_message:
    db  "PIC: invalid or unsupported ICW2 value", 0

pic_data_write_invalid_icw3:
    add pic_data_write_invalid_icw3_message, 0, [rb - 1]
    arb -1
    call report_error

pic_data_write_invalid_icw3_message:
    db  "PIC: invalid or unsupported ICW3 value", 0
.ENDFRAME

##########
pic_status_read:
.FRAME addr; value                      # returns value
    arb -1

    # Should we return the in-service register, or the interrupt request register?
    jnz [pic_read_in_service], pic_status_read_in_service

    # Build the interrupt request register (IRR) from individual bits
    mul [pic_request_irq7], 2, [rb + value]
    add [pic_request_irq6], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_request_irq5], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_request_irq4], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_request_irq3], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_request_irq2], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_request_irq1], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_request_irq0], 0, [rb + value]

    jz  0, pic_status_read_done

pic_status_read_in_service:
    # Build the in-service register (ISR) from individual bits
    mul [pic_in_service_irq7], 2, [rb + value]
    add [pic_in_service_irq6], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_in_service_irq5], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_in_service_irq4], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_in_service_irq3], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_in_service_irq2], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_in_service_irq1], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_in_service_irq0], 0, [rb + value]

pic_status_read_done:
    # PIC logging
    jz  [config_log_pic], pic_status_read_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call pic_status_read_log

pic_status_read_after_log:
    arb 1
    ret 1
.ENDFRAME

##########
pic_data_read:
.FRAME addr; value                      # returns value
    arb -1

    # Build the interrupt mask register (IMR) from individual bits
    mul [pic_mask_irq7], 2, [rb + value]
    add [pic_mask_irq6], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_mask_irq5], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_mask_irq4], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_mask_irq3], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_mask_irq2], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_mask_irq1], 0, [rb + value]
    mul [rb + value], 2, [rb + value]
    add [pic_mask_irq0], 0, [rb + value]

    # PIC logging
    jz  [config_log_pic], pic_data_read_after_log

    add [rb + value], 0, [rb - 1]
    arb -1
    call pic_data_read_log

pic_data_read_after_log:
    arb 1
    ret 1
.ENDFRAME

##########
pic_command_write_log:
.FRAME value;
    add pic_command_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_command_write_log_start:
    db  31, 31, 31, "pic command write: value 0x", 0
.ENDFRAME

##########
pic_data_write_log:
.FRAME value;
    add pic_data_write_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_data_write_log_start:
    db  31, 31, 31, "pic data write: value 0x", 0
.ENDFRAME

##########
pic_status_read_log:
.FRAME value;
    add pic_status_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_status_read_log_start:
    db  31, 31, 31, "pic status read: value 0x", 0
.ENDFRAME

##########
pic_data_read_log:
.FRAME value;
    add pic_data_read_log_start, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + value], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 1

pic_data_read_log_start:
    db  31, 31, 31, "pic data read: value 0x", 0
.ENDFRAME

##########

# PIC states; the numbers are used in a jump table
.SYMBOL S_DEFAULT                   0
.SYMBOL S_EXPECT_ICW2               1
.SYMBOL S_EXPECT_ICW4               2

pic_state:
    db  S_DEFAULT

pic_read_in_service:
    db  0

pic_request_irqs:
pic_request_irq0:
    db  0
pic_request_irq1:
    db  0
pic_request_irq2:
    db  0
pic_request_irq3:
    db  0
pic_request_irq4:
    db  0
pic_request_irq5:
    db  0
pic_request_irq6:
    db  0
pic_request_irq7:
    db  0

pic_in_service_irqs:
pic_in_service_irq0:
    db  0
pic_in_service_irq1:
    db  0
pic_in_service_irq2:
    db  0
pic_in_service_irq3:
    db  0
pic_in_service_irq4:
    db  0
pic_in_service_irq5:
    db  0
pic_in_service_irq6:
    db  0
pic_in_service_irq7:
    db  0

pic_mask_irqs:
pic_mask_irq0:
    db  0
pic_mask_irq1:
    db  0
pic_mask_irq2:
    db  0
pic_mask_irq3:
    db  0
pic_mask_irq4:
    db  0
pic_mask_irq5:
    db  0
pic_mask_irq6:
    db  0
pic_mask_irq7:
    db  0

.EOF

During this time (interrupt servicing), all interrupts are masked out by the Interrupt Mask Register (IMR).
In other words, this disables all hardware interrupts until a request has been made to end the interrupt.
this requires an End of Interrupt (EOI) command to be sent to the PIC.
When a hardware interrupt occurs, The 8259A Masks out all other interrupts until it recieves an End of Interrupt (EOI) signal. 



After the EOI signal has been sent to the PIC through the Primary PIC's Command Register, The PIC cleares the approprate bit in the In Service Register (IRR), and is now ready to service new interrupts. 



Repeat, LOCK and segment override prefixes are considered "part of" the instructions they prefix; no interrupt is recognized between execution of a prefix and an instruction.
A MOV (move) to segment register instruction and a POP segment register instruction are treated similarly: no interrupt is recognized until after the following instruction.
repeated string instructions, where an interrupt request is recognized in the middle of an instruction




 the PIC sets a bit internally telling one of the inputs needs servicing. It then checks whether that channel is masked or not, and whether there's an interrupt already pending. If the channel is unmasked and there's no interrupt pending, the PIC will raise the interrupt line.



The PIC that answers looks up the "vector offset" variable stored internally and adds the input line to form the requested interrupt number.

interrupt vector byte, lower 3 bits are not usable (so must be divisible by 8)