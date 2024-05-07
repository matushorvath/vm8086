.EXPORT execute_movs_b
#.EXPORT execute_movs_w
#.EXPORT execute_cmps_b
#.EXPORT execute_cmps_w
#.EXPORT execute_scas_b
#.EXPORT execute_scas_w
#.EXPORT execute_lods_b
#.EXPORT execute_lods_w
#.EXPORT execute_stos_b
#.EXPORT execute_stos_w

# From loop.s
.IMPORT dec_cx

# From memory.s
.IMPORT read_b
#.IMPORT read_w
.IMPORT write_b
#.IMPORT write_w

# From prefix.s
.IMPORT ds_segment_prefix
.IMPORT rep_prefix

# From state.s
.IMPORT reg_al
#.IMPORT reg_ax
.IMPORT reg_cx
.IMPORT reg_si
.IMPORT reg_di
.IMPORT reg_es
.IMPORT flag_direction
#.IMPORT flag_zero
#.IMPORT inc_ip_b


# TODO implement REPZ/REPNZ
# The REP prefix can be added to the INS, OUTS, MOVS, LODS, and STOS instructions, and the
# REPE, REPNE, REPZ, and REPNZ prefixes can be added to the CMPS and SCAS instructions. 

# TODO 8086 check what REPNZ does with MOVS and other instructions; probably works same as REP/REPZ?


##########
execute_movs_b:
.FRAME delta, src_addr, dst_addr, addr, tmp
    arb -X

    # Operation size is 1 byte
    add 1, 0, [rb + delta]

    # Adjust delta based on direction flag
    mul -2, [flag_direction], [rb + tmp]
    add 1, [rb + tmp], [rb + tmp]
    mul [rb + delta], [rb + tmp], [rb + delta]

    # Precalculate source address
    add [ds_segment_prefix], 0, [ip + 1]
    mul [0], 0x10, [rb + src_addr]
    add [reg_si], [rb + src_addr], [rb + src_addr]

    lt  [rb + src_addr], 0x100000, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_src_addr_done

    add [rb + src_addr], -0x100000, [rb + src_addr]

execute_movs_b_src_addr_done:
    # Precalculate destination address
    mul [reg_es], 0x10, [rb + dst_addr]
    add [reg_di], [rb + dst_addr], [rb + dst_addr]

    lt  [rb + dst_addr], 0x100000, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_dst_addr_done

    add [rb + dst_addr], -0x100000, [rb + dst_addr]

execute_movs_b_dst_addr_done 
    # Check for REPZ/REPNZ
    jz  [rep_prefix], execute_movs_b_after_rep

execute_movs_b_rep:
    # Stop if CX == 0
    add [reg_cx + 0], [reg_cx + 1], [rb + tmp]
    jz  [rb + tmp], execute_movs_b_done

    # TODO process pending interrupts

    call dec_cx

execute_movs_b_after_rep:
    # Copy one byte from source to destination
    add [rb + src_addr], 0, [rb - 1]
    arb -1
    call read_b

    add [rb + dst_addr], 0, [rb - 1]
    add [rb - 3], 0, [rb - 2]
    arb -2
    call write_b

    # Are we incrementing or decrementing SI/DI?
    jz  [flag_direction], execute_movs_b_increment

    # TODO Decrement SI, DI and both addresses

execute_movs_b_increment:
    # Increment SI, low byte
    add [reg_si + 0], [rb + delta], [reg_si + 0]

    # Check for carry out of low byte
    lt  [reg_si + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_increment_si_done

    add [reg_si + 0], -0x100, [reg_si + 0]
    add [reg_si + 1], 1, [reg_si + 1]

    # Check for carry out of high byte
    lt  [reg_si + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_b_done

    add [reg_si + 1], -0x100, [reg_si + 1]

execute_movs_b_increment_si_done:

# inc/dec si by 1/2
# inc/dec di by 1/2
# inc/dec src_addr by 1/2
# inc/dec dst_addr by 1/2




xxx remove
    # Increment the low byte
    add [reg_ip + 0], 1, [reg_ip + 0]

    # Check for carry out of low byte
    lt  [reg_ip + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_b_done

    add [reg_ip + 0], -0x100, [reg_ip + 0]
    add [reg_ip + 1], 1, [reg_ip + 1]

    # Check for carry out of high byte
    lt  [reg_ip + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_ip_b_done

    add [reg_ip + 1], -0x100, [reg_ip + 1]



    # check ZF for CMPS/SCAS
    # if prefix, goto rep:

execute_movs_b_done:
    arb X
    ret 0
.ENDFRAME

.EOF
