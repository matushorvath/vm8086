# From cpu/devices.s
.IMPORT register_devices

# From cpu/execute.s
.IMPORT execute

# From cpu/images.s
.IMPORT init_rom_image

# From the binary.o
.IMPORT binary_image

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
    ds  100, 0
stack:

.EOF
