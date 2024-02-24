# From exec.s
.IMPORT execute

# From init.s
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
    arb -0

    call init_memory
    call init_state

    call execute

    arb 0
    ret 0
.ENDFRAME

##########
    ds  50, 0
stack:

.EOF
