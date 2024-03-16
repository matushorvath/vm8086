.EXPORT execute_int3
.EXPORT execute_into
.EXPORT execute_int
.EXPORT execute_iret

# From memory.s
.IMPORT read_w

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
.FRAME type;
    # Push flags, then disable TF and IF
    call execute_pushf

    add 0, 0, [flag_trap]
    add 0, 0, [flag_interrupt]

    # Push CS
    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    arb -1
    call push_w

    # Load new CS from the interrupt vector (physical address type * 4 + 2)
    mul type, 4, [rb + tmp]
    add [rb + tmp], 2, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call read_w

    add [rb - 3], 0, [reg_cs + 0]
    add [rb - 4], 0, [reg_cs + 1]

    # Push IP
    add [reg_ip], 0, [rb - 1]
    arb -1
    call push_w

    # Load new IP from the interrupt vector (physical address type * 4 + 0)
    mul type, 4, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call read_w

    mul [rb - 4], 0x100, [reg_ip]
    add [reg_ip], [rb - 3], [reg_ip]

    ret 1
.ENDFRAME


##########
execute_iret:
.FRAME
    # Pop IP

    mul type, 4, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call read_w

    mul [rb - 4], 0x100, [reg_ip]
    add [reg_ip], [rb - 3], [reg_ip]


pop ip
pop cs
popf


    # Push flags, then disable TF and IF
    call execute_pushf

    add 0, 0, [flag_trap]
    add 0, 0, [flag_interrupt]

    # Push CS
    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    arb -1
    call push_w

    # Load new CS from the interrupt vector (physical address type * 4 + 2)
    mul type, 4, [rb + tmp]
    add [rb + tmp], 2, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call read_w

    add [rb - 3], 0, [reg_cs + 0]
    add [rb - 4], 0, [reg_cs + 1]

    # Push IP
    add [reg_ip], 0, [rb - 1]
    arb -1
    call push_w

    # Load new IP from the interrupt vector (physical address type * 4 + 0)
    mul type, 4, [ip + 1]
    add [0], 0, [rb - 1]
    arb -1
    call read_w

    mul [rb - 4], 0x100, [reg_ip]
    add [reg_ip], [rb - 3], [reg_ip]

    ret 1
.ENDFRAME


.EOF

# TODO
    db  not_implemented, 0 # TODO    db  execute_int3, 0                                 # 0xcc INT 3
    db  not_implemented, 0 # TODO    db  execute_int, arg_immediate_b                    # 0xcd INT IMMED8
    db  not_implemented, 0 # TODO    db  execute_into, 0                                 # 0xce INTO
    db  not_implemented, 0 # TODO    db  execute_iret, 0                                 # 0xcf IRET




##########
execute_brk:
.FRAME ip_hi, ip_lo
    arb -2

    # Increment ip with wraparound, since we need to push that value. We will overwrite ip soon anyway.
    # This implements a one byte gap after a BRK instruction (BRK <gap for handler use> <RTI returns here>).
    call inc_ip

    # Split ip into high and low part
    add [reg_ip], 0, [rb - 1]
    arb -1
    call split_16_8_8

    add [rb - 3], 0, [rb + ip_hi]
    add [rb - 4], 0, [rb + ip_lo]

    # Push both parts of ip
    add [rb + ip_hi], 0, [rb - 1]
    arb -1
    call push

    add [rb + ip_lo], 0, [rb - 1]
    arb -1
    call push

    # Pack sr and push it too
    call pack_sr
    add [rb - 2], 0, [rb - 1]
    arb -1
    call push

    # Set the interrupt flag
    add 1, 0, [flag_interrupt]

    # Read the IRQ vector from 0xfffe and 0xffff
    add 0xffff, 0, [rb - 1]
    arb -1
    call read
    mul [rb - 3], 0x100, [reg_ip]           # read(0xffff) * 0x100 -> [reg_ip]

    add 0xfffe, 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [reg_ip], [reg_ip]      # read(0xfffe) + read(0xffff) * 0x100 -> [reg_ip]

    arb 2
    ret 0
.ENDFRAME




##########
execute_rti:
.FRAME
    # Pull sr and unpack it into flags_*
    call pop
    add [rb - 2], 0, [rb - 1]
    arb -1
    call unpack_sr

    # Pull return addres lo and hi and update reg_ip
    call pop
    add [rb - 2], 0, [reg_ip]

    call pop
    mul [rb - 2], 0x100, [rb - 2]
    add [reg_ip], [rb - 2], [reg_ip]

    ret 0
.ENDFRAME

