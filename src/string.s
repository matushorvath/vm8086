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
# .IMPORT reg_al
#.IMPORT reg_ax
.IMPORT reg_cx
.IMPORT reg_si
.IMPORT reg_di
.IMPORT reg_es
.IMPORT flag_direction
.IMPORT flag_zero

# TODO implement REPZ/REPNZ
# The REP prefix can be added to the INS, OUTS, MOVS, LODS, and STOS instructions, and the
# REPE, REPNE, REPZ, and REPNZ prefixes can be added to the CMPS and SCAS instructions. 

# TODO 8086 check what REPNZ does with MOVS and other instructions; probably works same as REP/REPZ?

# TODO test all the wraparounds: SI/DI (16-bit), src/dst physical address (20-bit)

##########
execute_movs_b:
.FRAME delta, check_zf, src_seg_addr, dst_seg_addr, src_addr, dst_addr, tmp
    arb -7

    # Operation size is 1 byte
    # TODO handle word operations
    add 1, 0, [rb + delta]

    # Do not check ZF
    # TODO check ZF for CMPS/SCAS
    add 0, 0, [rb + check_zf]

    # Negate delta if DF is set for decrementing
    mul -2, [flag_direction], [rb + tmp]
    add 1, [rb + tmp], [rb + tmp]
    mul [rb + delta], [rb + tmp], [rb + delta]

    # Precalculate segment base addresses
    add [ds_segment_prefix], 0, [ip + 1]
    mul [0], 0x10, [rb + src_seg_addr]
    mul [reg_es], 0x10, [rb + dst_seg_addr]

    # Check for REPZ/REPNZ
    jz  [rep_prefix], execute_movs_b_after_rep

execute_movs_b_rep:
    # Stop if CX == 0
    add [reg_cx + 0], [reg_cx + 1], [rb + tmp]
    jz  [rb + tmp], execute_movs_b_done

    # TODO process pending interrupts

    call dec_cx

execute_movs_b_after_rep:
    # Calculate source physical address
    add [reg_si], [rb + src_seg_addr], [rb + src_addr]

    lt  [rb + src_addr], 0x100000, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_src_addr_done

    add [rb + src_addr], -0x100000, [rb + src_addr]

execute_movs_b_src_addr_done:
    # Calculate destination physical address
    add [reg_di], [rb + dst_seg_addr], [rb + dst_addr]

    lt  [rb + dst_addr], 0x100000, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_dst_addr_done

    add [rb + dst_addr], -0x100000, [rb + dst_addr]

execute_movs_b_dst_addr_done:
    # Copy one byte from source to destination
    # TODO handle word operations
    add [rb + src_addr], 0, [rb - 1]
    arb -1
    call read_b

    add [rb + dst_addr], 0, [rb - 1]
    add [rb - 3], 0, [rb - 2]
    arb -2
    call write_b

    # Are we incrementing or decrementing SI/DI?
    jz  [flag_direction], execute_movs_b_increment

    # Decrement SI
    add [reg_si + 0], [rb + delta], [reg_si + 0]

    # Check for borrow into low byte
    lt  [reg_si + 0], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_movs_b_decrement_si_done

    add [reg_si + 0], 0x100, [reg_si + 0]
    add [reg_si + 1], -1, [reg_si + 1]

    # Check for borrow into high byte
    lt  [reg_si + 1], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_movs_b_decrement_si_done

    add [reg_si + 1], 0x100, [reg_si + 1]

execute_movs_b_decrement_si_done:
    # Decrement DI
    add [reg_di + 0], [rb + delta], [reg_di + 0]

    # Check for borrow into low byte
    lt  [reg_di + 0], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_movs_b_decrement_di_done

    add [reg_di + 0], 0x100, [reg_di + 0]
    add [reg_di + 1], -1, [reg_di + 1]

    # Check for borrow into high byte
    lt  [reg_di + 1], 0x00, [rb + tmp]
    jz  [rb + tmp], execute_movs_b_decrement_di_done

    add [reg_di + 1], 0x100, [reg_di + 1]

execute_movs_b_decrement_di_done:
    jz  0, execute_movs_b_after_si_di

execute_movs_b_increment:
    # Increment SI
    add [reg_si + 0], [rb + delta], [reg_si + 0]

    # Check for carry out of low byte
    lt  [reg_si + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_increment_si_done

    add [reg_si + 0], -0x100, [reg_si + 0]
    add [reg_si + 1], 1, [reg_si + 1]

    # Check for carry out of high byte
    lt  [reg_si + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_increment_si_done

    add [reg_si + 1], -0x100, [reg_si + 1]

execute_movs_b_increment_si_done:
    # Increment DI
    add [reg_di + 0], [rb + delta], [reg_di + 0]

    # Check for carry out of low byte
    lt  [reg_di + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_increment_di_done

    add [reg_di + 0], -0x100, [reg_di + 0]
    add [reg_di + 1], 1, [reg_di + 1]

    # Check for carry out of high byte
    lt  [reg_di + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], execute_movs_b_increment_di_done

    add [reg_di + 1], -0x100, [reg_di + 1]

execute_movs_b_increment_di_done:
execute_movs_b_after_si_di:
    # If there is no REP prefix, we are done
    jz  [rep_prefix], execute_movs_b_done

    # If we don't need to check ZF, loop
    jz  [rb + check_zf], execute_movs_b_rep

    # Exit the loop if ZF does not match the REPZ/REPNZ prefix
    eq  [rep_prefix], '1', [rb + tmp]
    eq  [flag_zero], [rb + tmp], [rb + tmp]
    jz  [rb + tmp], execute_movs_b_done

    jz  0, execute_movs_b_rep

execute_movs_b_done:
    arb 7
    ret 0
.ENDFRAME

.EOF
