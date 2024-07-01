.EXPORT execute_int
.EXPORT execute_int3
.EXPORT execute_into
.EXPORT execute_iret
.EXPORT interrupt

# From the config file
.IMPORT config_log_cs_change
.IMPORT config_log_dos
.IMPORT config_log_fdc
.IMPORT config_log_int

# From log_cs_change.s
.IMPORT log_cs_change

# From log_dos.s
.IMPORT log_dos_21_call
.IMPORT log_dos_21_iret

# From memory.s
.IMPORT read_b
.IMPORT read_cs_ip_b

# From stack.s
.IMPORT pop_w
.IMPORT popf
.IMPORT push_w
.IMPORT pushf

# From state.s
.IMPORT reg_ah
.IMPORT reg_ax
.IMPORT reg_cs
.IMPORT reg_ip
.IMPORT inc_ip_b

.IMPORT flag_interrupt
.IMPORT flag_overflow
.IMPORT flag_trap

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num_16_b
.IMPORT print_num_16_w

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
.FRAME type; vector, tmp
    arb -2

    # Interrupt logging
    jz  [config_log_int], interrupt_after_log_int

    add [rb + type], 0, [rb - 1]
    arb -1
    call interrupt_log_int

interrupt_after_log_int:
    # Floppy controller logging
    jz  [config_log_fdc], interrupt_after_log_fdc

    eq  [rb + type], 0x13, [rb + tmp]
    jz  [rb + tmp], interrupt_after_log_fdc_13
    call interrupt_log_fdc_13

interrupt_after_log_fdc_13:
    eq  [rb + type], 0x0e, [rb + tmp]
    jz  [rb + tmp], interrupt_after_log_fdc
    call interrupt_log_fdc_0e

interrupt_after_log_fdc:
    # DOS function logging
    jz  [config_log_dos], interrupt_after_log_dos

    # Is this the DOS function call?
    eq  [rb + type], 0x21, [rb + tmp]
    jz  [rb + tmp], interrupt_after_log_dos

    # Save CS:IP that called DOS, so we can also log the return
    add [reg_cs + 0], 0, [dos_21_cs + 0]
    add [reg_cs + 1], 0, [dos_21_cs + 1]
    add [reg_ip + 0], 0, [dos_21_ip + 0]
    add [reg_ip + 1], 0, [dos_21_ip + 1]

    call log_dos_21_call

interrupt_after_log_dos:
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

    # TODO reset/halt for triple fault

    # Log CS change
    jz  [config_log_cs_change], execute_interrupt_after_log_cs_change
    call log_cs_change

execute_interrupt_after_log_cs_change:
    arb 2
    ret 1
.ENDFRAME

##########
interrupt_log_int:
.FRAME type;
    call log_start

    add interrupt_log_int_type, 0, [rb - 1]
    arb -1
    call print_str

    add [rb + type], 0, [rb - 1]
    arb -1
    call print_num_16_b

    add interrupt_log_int_ax, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_ax + 1], 0x100, [rb - 1]
    add [reg_ax + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    out 10
    ret 1

interrupt_log_int_type:
    db  "int 0x", 0
interrupt_log_int_ax:
    db  ", ax=0x", 0
.ENDFRAME

##########
interrupt_log_fdc_13:
.FRAME
    call log_start

    add interrupt_log_fdc_13_start, 0, [rb - 1]
    arb -1
    call print_str

    add [reg_ah], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out 10
    ret 0

interrupt_log_fdc_13_start:
    db  "int 0x13, fn 0x", 0
.ENDFRAME

##########
interrupt_log_fdc_0e:
.FRAME
    call log_start

    add interrupt_log_fdc_0e_start, 0, [rb - 1]
    arb -1
    call print_str

    out 10
    ret 0

interrupt_log_fdc_0e_start:
    db  "irq 6", 0
.ENDFRAME

##########
execute_iret:
.FRAME
    # Pop IP and CS
    call pop_w
    add [rb - 2], 0, [reg_ip + 0]
    add [rb - 3], 0, [reg_ip + 1]

    call pop_w
    add [rb - 2], 0, [reg_cs + 0]
    add [rb - 3], 0, [reg_cs + 1]

    # DOS function logging
    jz  [config_log_dos], execute_iret_after_log_fdc

    # Only log if we are returning back from where DOS was called
    eq  [reg_ip + 0], [dos_21_ip + 0], [rb - 1]
    jz  [rb - 1], execute_iret_after_log_fdc
    eq  [reg_ip + 1], [dos_21_ip + 1], [rb - 1]
    jz  [rb - 1], execute_iret_after_log_fdc
    eq  [reg_cs + 0], [dos_21_cs + 0], [rb - 1]
    jz  [rb - 1], execute_iret_after_log_fdc
    eq  [reg_cs + 1], [dos_21_cs + 1], [rb - 1]
    jz  [rb - 1], execute_iret_after_log_fdc

    add -1, 0, [dos_21_ip + 0]
    add -1, 0, [dos_21_ip + 1]
    add -1, 0, [dos_21_cs + 0]
    add -1, 0, [dos_21_cs + 1]

    call log_dos_21_iret

execute_iret_after_log_fdc:
    # Pop flags
    call popf

    # Log CS change
    jz  [config_log_cs_change], execute_iret_after_log_cs_change
    call log_cs_change

execute_iret_after_log_cs_change:
    ret 0
.ENDFRAME

##########
dos_21_cs:
    db  -1
    db  -1
dos_21_ip:
    db  -1
    db  -1

.EOF
