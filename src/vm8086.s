# From exec.s
.IMPORT execute

# From load.s
.IMPORT init_memory

# From state.s
.IMPORT init_state

##########
# Entry point
    arb stack

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
