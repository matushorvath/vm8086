.EXPORT execute_brk
.EXPORT execute_jmp
.EXPORT execute_jsr
.EXPORT execute_rti
.EXPORT execute_rts

.EXPORT execute_bcc
.EXPORT execute_bcs
.EXPORT execute_bne
.EXPORT execute_beq
.EXPORT execute_bpl
.EXPORT execute_bmi
.EXPORT execute_bvc
.EXPORT execute_bvs

# From memory.s
.IMPORT push
.IMPORT pull
.IMPORT read

# From state.s
.IMPORT flag_negative
.IMPORT flag_overflow
.IMPORT flag_interrupt
.IMPORT flag_zero
.IMPORT flag_carry
.IMPORT reg_pc
.IMPORT pack_sr
.IMPORT unpack_sr

# From util.s
.IMPORT incpc
.IMPORT mod_16bit
.IMPORT split_16_8_8

##########
execute_brk:
.FRAME pc_hi, pc_lo
    arb -2

    # Increment pc with wraparound, since we need to push that value. We will overwrite pc soon anyway.
    # This implements a one byte gap after a BRK instruction (BRK <gap for handler use> <RTI returns here>).
    call incpc

    # Split pc into high and low part
    add [reg_pc], 0, [rb - 1]
    arb -1
    call split_16_8_8

    add [rb - 4], 0, [rb + pc_hi]
    add [rb - 3], 0, [rb + pc_lo]

    # Push both parts of pc
    add [rb + pc_hi], 0, [rb - 1]
    arb -1
    call push

    add [rb + pc_lo], 0, [rb - 1]
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
    add 65535, 0, [rb - 1]
    arb -1
    call read
    mul [rb - 3], 256, [reg_pc]           # read(0xffff) * 0x100 -> [reg_pc]

    add 65534, 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [reg_pc], [reg_pc]      # read(0xfffe) + read(0xffff) * 0x100 -> [reg_pc]

    arb 2
    ret 0
.ENDFRAME

##########
execute_jmp:
.FRAME addr
    add [rb + addr], 0, [reg_pc]
    ret 1
.ENDFRAME

##########
execute_jsr:
.FRAME addr; ret_hi, ret_lo
    arb -2

    # JSR pushes pc - 1 to the stack, and rts adds + 1 to the address after it's pulled
    # (JSR <addr-lo> ^<addr-hi> - the address pushed to stack is marked with a "^").

    # Decrement pc with wraparound
    add [reg_pc], -1, [rb - 1]
    arb -1
    call mod_16bit

    # Split the return addres into high and low part
    add [rb - 3], 0, [rb - 1]
    arb -1
    call split_16_8_8

    add [rb - 4], 0, [rb + ret_hi]
    add [rb - 3], 0, [rb + ret_lo]

    # Push both parts of the return address
    add [rb + ret_hi], 0, [rb - 1]
    arb -1
    call push

    add [rb + ret_lo], 0, [rb - 1]
    arb -1
    call push

    # Jump to address
    add [rb + addr], 0, [reg_pc]

    arb 2
    ret 1
.ENDFRAME

##########
execute_rti:
.FRAME
    # Pull sr and unpack it into flags_*
    call pull
    add [rb - 2], 0, [rb - 1]
    arb -1
    call unpack_sr

    # Pull return addres lo and hi and update reg_pc
    call pull
    add [rb - 2], 0, [reg_pc]

    call pull
    mul [rb - 2], 256, [rb - 2]
    add [reg_pc], [rb - 2], [reg_pc]

    ret 0
.ENDFRAME

##########
execute_rts:
.FRAME
    # Pull return addres lo and hi and update reg_pc
    call pull
    add [rb - 2], 0, [reg_pc]

    call pull
    mul [rb - 2], 256, [rb - 2]
    add [reg_pc], [rb - 2], [reg_pc]

    # Increment reg_pc by 1 with wraparound
    add [reg_pc], 1, [rb - 1]
    arb -1
    call mod_16bit
    add [rb - 3], 0, [reg_pc]

    ret 0
.ENDFRAME

##########
execute_bcc:
.FRAME addr
    jnz flag_carry, execute_bcc_done
    add [rb + addr], 0, [reg_pc]

execute_bcc_done:
    ret 1
.ENDFRAME

##########
execute_bcs:
.FRAME addr
    jz  flag_carry, execute_bcs_done
    add [rb + addr], 0, [reg_pc]

execute_bcs_done:
    ret 1
.ENDFRAME

##########
execute_bne:
.FRAME addr
    jnz flag_zero, execute_bne_done
    add [rb + addr], 0, [reg_pc]

execute_bne_done:
    ret 1
.ENDFRAME

##########
execute_beq:
.FRAME addr
    jz  flag_zero, execute_beq_done
    add [rb + addr], 0, [reg_pc]

execute_beq_done:
    ret 1
.ENDFRAME

##########
execute_bpl:
.FRAME addr
    jnz flag_negative, execute_bpl_done
    add [rb + addr], 0, [reg_pc]

execute_bpl_done:
    ret 1
.ENDFRAME

##########
execute_bmi:
.FRAME addr
    jz  flag_negative, execute_bmi_done
    add [rb + addr], 0, [reg_pc]

execute_bmi_done:
    ret 1
.ENDFRAME

##########
execute_bvc:
.FRAME addr
    jnz flag_overflow, execute_bvc_done
    add [rb + addr], 0, [reg_pc]

execute_bvc_done:
    ret 1
.ENDFRAME

##########
execute_bvs:
.FRAME addr
    jz  flag_overflow, execute_bvs_done
    add [rb + addr], 0, [reg_pc]

execute_bvs_done:
    ret 1
.ENDFRAME

.EOF
