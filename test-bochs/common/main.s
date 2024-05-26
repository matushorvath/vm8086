# From devices.s
.IMPORT register_devices

# From exec.s
.IMPORT execute

# From init_binary.s
.IMPORT init_binary

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
    call init_binary
    call register_devices
    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF
