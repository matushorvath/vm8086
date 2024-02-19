# from libxib.s
.IMPORT print_str

##########
# entry point
    arb stack

    call main
    hlt

##########
main:
.FRAME
    arb -0

    add TODO_remove_message, 0, [rb - 1]
    arb -1
    call print_str

    arb 0
    ret 0
.ENDFRAME

##########
# strings

TODO_remove_message:
    db  "Hello world!", 0

##########
    ds  50, 0
stack:

.EOF
