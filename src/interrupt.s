.EXPORT execute_int
.EXPORT execute_int3
.EXPORT execute_into
.EXPORT execute_iret

# From memory.s
.IMPORT read_w

# From stack.s
.IMPORT pop_w
.IMPORT popf
.IMPORT push_w
.IMPORT pushf

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT flag_interrupt
.IMPORT flag_overflow
.IMPORT flag_trap

##########
execute_int3:
.FRAME
    add 3, 0, [rb - 1]
    arb -1
    call execute_int

    ret 0
.ENDFRAME

##########
execute_into:
.FRAME
    jz  [flag_overflow], execute_into_done

    add 4, 0, [rb - 1]
    arb -1
    call execute_int

execute_into_done:
    ret 0
.ENDFRAME

##########
execute_int:
.FRAME type; tmp
    arb -1

    # Push flags, then disable TF and IF
    call pushf

    add 0, 0, [flag_trap]
    add 0, 0, [flag_interrupt]

    # Push CS
    add [reg_cs + 0], 0, [rb - 1]
    add [reg_cs + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Load new CS from the interrupt vector (physical address type * 4 + 2)
    mul [rb + type], 4, [rb + tmp]
    add [rb + tmp], 2, [rb - 1]
    arb -1
    call read_w

    add [rb - 3], 0, [reg_cs + 0]
    add [rb - 4], 0, [reg_cs + 1]

    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Load new IP from the interrupt vector (physical address type * 4 + 0)
    mul type, 4, [rb - 1]
    arb -1
    call read_w

    add [rb - 3], 0, [reg_ip + 0]
    add [rb - 4], 0, [reg_ip + 1]

    arb 1
    ret 1
.ENDFRAME

##########
execute_iret:
.FRAME
    # Pop IP, CS and flags
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    call pop_w
    add [rb - 2], 0, [reg_cs + 0]
    add [rb - 3], 0, [reg_cs + 1]

    call popf

    ret 0
.ENDFRAME

.EOF
