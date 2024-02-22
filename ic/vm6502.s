# From init.s
.IMPORT init_memory

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

    arb 0
    ret 0
.ENDFRAME

##########
    ds  50, 0
stack:

.EOF
