.EXPORT interrupt_request
.EXPORT schedule_interrupt_requests

.EXPORT irq_execute
.EXPORT irq_need_to_execute

# From the config file
.IMPORT config_log_pic

# From pic_8259a_log.s
.IMPORT interrupt_request_log

# From pic_8259a_ports.s
.IMPORT pic_lowest_irq_in_service
.IMPORT pic_request_irqs
.IMPORT pic_in_service_irqs
.IMPORT pic_mask_irqs

# From cpu/interrupt.s
.IMPORT interrupt

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_16_b

##########
interrupt_request:
.FRAME number;
    # PIC logging
    jz  [config_log_pic], .after_log

    add [rb + number], 0, [rb - 1]
    arb -1
    call interrupt_request_log

.after_log:
    # Save the interrupt request
    add pic_request_irqs, [rb + number], [ip + 3]
    add 1, 0, [0]

    # Reschedule which request will be executed next
    call schedule_interrupt_requests

    ret 1
.ENDFRAME

##########
schedule_interrupt_requests:
.FRAME number, tmp
    arb -2

    # This function pre-calculates which IRQ should be the next one to execute
    # This allows us to have very simple and fast logic in the execute function of the cpu

    add 0, 0, [irq_need_to_execute]

    add -1, 0, [rb + number]

.loop:
    add [rb + number], 1, [rb + number]

    # Is there an unmasked request for this number?
    add pic_request_irqs, [rb + number], [ip + 1]
    jz  [0], .loop
    add pic_mask_irqs, [rb + number], [ip + 1]
    jnz [0], .loop

    # Yes, there is a request; are we already processing a request of same or higher priority?
    lt  [rb + number], [pic_lowest_irq_in_service], [rb + tmp]
    # Yes, and all numbers after this will also have lower priority, so we can skip them
    jz  [rb + tmp], .done

    # Not executing a request of same or higher priority, so this is the next IRQ to execute
    add 1, 0, [irq_need_to_execute]
    add [rb + number], 0, [irq_number_to_execute]

.done:
    arb 2
    ret 0
.ENDFRAME

##########
irq_execute:
.FRAME
    arb -1

    # Execute interrupt request that was pre-decided in schedule_interrupt_requests
    # Assumption: irq_need_to_execute is 1, irq_number_to_execute has a valid IRQ number

    # Mark the IRQ as in service and no longer requested
    add pic_request_irqs, [irq_number_to_execute], [ip + 3]
    add 0, 0, [0]
    add pic_in_service_irqs, [irq_number_to_execute], [ip + 3]
    add 1, 0, [0]
    add [irq_number_to_execute], 0, [pic_lowest_irq_in_service]

    # Execute the interrupt
    add 8, [irq_number_to_execute], [rb - 1]
    arb -1
    call interrupt

    # Schedule which request will be executed next
    call schedule_interrupt_requests

    arb 1
    ret 0
.ENDFRAME

##########
irq_need_to_execute:
    db  0

irq_number_to_execute:
    db  0

.EOF
