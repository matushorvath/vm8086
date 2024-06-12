# From cga/cga.s
.IMPORT init_cga

# From cpu/execute.s
.IMPORT execute

# From cpu/init_binary.s
.IMPORT init_binary

# From shutdown.s
.IMPORT init_shutdown_port

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
    call init_cga
    call init_shutdown_port

    call execute

    ret 0
.ENDFRAME

##########
    ds  100, 0
stack:

.EOF
