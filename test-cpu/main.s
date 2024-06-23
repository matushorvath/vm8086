.EXPORT irq_execute
.EXPORT irq_need_to_execute

# From cpu/execute.s
.IMPORT execute

# From init_test.s
.IMPORT init_processor_test

# From print_output.s
.IMPORT print_output

##########
# Entry point
    arb stack

    # Overwrite the first instruction with 'hlt', so in case
    # we ever jump to 0 by mistake, we halt immediately
    add 99, 0, [0]

    call main
    hlt

##########
main:
.FRAME
    call init_processor_test
    call execute
    call print_output

    ret 0
.ENDFRAME

##########
# Fake implementation of an IRQ controller
irq_need_to_execute:
    db  0
irq_execute:
    db  0

##########
    ds  100, 0
stack:

.EOF
