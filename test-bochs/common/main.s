.EXPORT irq_execute
.EXPORT irq_need_to_execute

# From the binary
.IMPORT binary_image

# From devices.s
.IMPORT register_devices

# From cpu/execute.s
.IMPORT execute

# From cpu/images.s
.IMPORT init_rom_image

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
    add 0xca000, 0, [rb - 1]
    add binary_image, 0, [rb - 2]
    arb -2
    call init_rom_image

    call register_devices
    call execute

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
