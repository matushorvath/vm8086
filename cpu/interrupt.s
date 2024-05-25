.EXPORT execute_int
.EXPORT execute_int3
.EXPORT execute_into
.EXPORT execute_iret
.EXPORT interrupt

# From memory.s
.IMPORT read_b
.IMPORT read_cs_ip_b

# From stack.s
.IMPORT pop_w
.IMPORT popf
.IMPORT push_w
.IMPORT pushf

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip_b

.IMPORT flag_interrupt
.IMPORT flag_overflow
.IMPORT flag_trap

##########
execute_int3:
.FRAME
    add 3, 0, [rb - 1]
    arb -1
    call interrupt

    ret 0
.ENDFRAME

##########
execute_into:
.FRAME
    jz  [flag_overflow], execute_into_done

    add 4, 0, [rb - 1]
    arb -1
    call interrupt

execute_into_done:
    ret 0
.ENDFRAME

##########
execute_int:
.FRAME type
    arb -1

    # Read interrupt type from 8-bit immediate argument
    call read_cs_ip_b
    add [rb - 2], 0, [rb + type]
    call inc_ip_b

    # Process the interrupt
    add [rb + type], 0, [rb - 1]
    arb -1
    call interrupt

    arb 1
    ret 0
.ENDFRAME

##########
interrupt:
.FRAME type; vector
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

    # Calculate physical address of the interrupt vector
    mul [rb + type], 4, [rb + vector]

    # Load new CS from [vector + 2]
    add [rb + vector], 2, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [reg_cs + 0]

    add [rb + vector], 3, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [reg_cs + 1]

    # Push IP
    add [reg_ip + 0], 0, [rb - 1]
    add [reg_ip + 1], 0, [rb - 2]
    arb -2
    call push_w

    # Load new IP from [vector]
    add [rb + vector], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [reg_ip + 0]

    add [rb + vector], 1, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [reg_ip + 1]

    # TODO raise #DF (INT 8) for double fault, reset for triple fault

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
