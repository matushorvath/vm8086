.EXPORT main

# From exec.s
.IMPORT execute

# From load.s
.IMPORT init_memory

# From state.s
.IMPORT init_state

##########
# Entry point
    arb stack

    # Overwrite the first instruction with 'hlt', so in case we ever
    # jump to 0 by mistake, we halt immediately
    # TODO this exits cleanly, instead make it crash on jump to 0
    add 99, 0, [0]

    call main
    hlt

##########
main:
.FRAME
    call init_memory
    call init_state

    call execute

    ret 0
.ENDFRAME

##########
    ds  50, 0
stack:

.EOF
