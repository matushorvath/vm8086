# From exec.s
# TODO .IMPORT execute

# From memory.s
# TODO .IMPORT init_memory

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
# TODO    call init_memory
    call init_state

# TODO    call execute

    ret 0
.ENDFRAME

##########
    ds  50, 0
stack:

.EOF
