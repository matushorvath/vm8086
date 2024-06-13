# From cpu/devices.s
.IMPORT register_devices

# From cpu/execute.s
.IMPORT execute

# From cpu/init_memory.s
.IMPORT init_memory

# From the binary.o
.IMPORT binary_count
.IMPORT binary_header
.IMPORT binary_data

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
    add [binary_count], 0, [rb - 2]
    add binary_header, 0, [rb - 3]
    add binary_data, 0, [rb - 4]
    arb -4
    call init_memory

    call register_devices
    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF
