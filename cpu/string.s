.EXPORT execute_movs_b
.EXPORT execute_movs_w
.EXPORT execute_cmps_b
.EXPORT execute_cmps_w
.EXPORT execute_scas_b
.EXPORT execute_scas_w
.EXPORT execute_lods_b
.EXPORT execute_lods_w
.EXPORT execute_stos_b
.EXPORT execute_stos_w

# From loop.s
.IMPORT dec_cx

# From memory.s
.IMPORT read_seg_off_b
.IMPORT read_seg_off_w
.IMPORT write_seg_off_b
.IMPORT write_seg_off_w

# From prefix.s
.IMPORT ds_segment_prefix
.IMPORT rep_prefix

# From state.s
.IMPORT reg_al
.IMPORT reg_ax
.IMPORT reg_cx
.IMPORT reg_si
.IMPORT reg_di
.IMPORT reg_es
.IMPORT flag_direction
.IMPORT flag_zero

# From sub_cmp.s
.IMPORT execute_cmp_b
.IMPORT execute_cmp_w

##########
.FRAME operation, do_si, do_di, index_delta, check_zf, src_seg, src_off, dst_seg, dst_off, tmp
    # Function with multiple entry points

execute_movs_b:
    arb -10

    add execute_string.movsb, 0, [rb + operation]
    add 1, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 1, 0, [rb + index_delta]
    add 0, 0, [rb + check_zf]

    jz  0, execute_string

execute_movs_w:
    arb -10

    add execute_string.movsw, 0, [rb + operation]
    add 1, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 2, 0, [rb + index_delta]
    add 0, 0, [rb + check_zf]

    jz  0, execute_string

execute_cmps_b:
    arb -10

    add execute_string.cmpsb, 0, [rb + operation]
    add 1, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 1, 0, [rb + index_delta]
    add 1, 0, [rb + check_zf]

    jz  0, execute_string

execute_cmps_w:
    arb -10

    add execute_string.cmpsw, 0, [rb + operation]
    add 1, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 2, 0, [rb + index_delta]
    add 1, 0, [rb + check_zf]

    jz  0, execute_string

execute_scas_b:
    arb -10

    add execute_string.scasb, 0, [rb + operation]
    add 0, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 1, 0, [rb + index_delta]
    add 1, 0, [rb + check_zf]

    jz  0, execute_string

execute_scas_w:
    arb -10

    add execute_string.scasw, 0, [rb + operation]
    add 0, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 2, 0, [rb + index_delta]
    add 1, 0, [rb + check_zf]

    jz  0, execute_string

execute_lods_b:
    arb -10

    add execute_string.lodsb, 0, [rb + operation]
    add 1, 0, [rb + do_si]
    add 0, 0, [rb + do_di]
    add 1, 0, [rb + index_delta]
    add 0, 0, [rb + check_zf]

    jz  0, execute_string

execute_lods_w:
    arb -10

    add execute_string.lodsw, 0, [rb + operation]
    add 1, 0, [rb + do_si]
    add 0, 0, [rb + do_di]
    add 2, 0, [rb + index_delta]
    add 0, 0, [rb + check_zf]

    jz  0, execute_string

execute_stos_b:
    arb -10

    add execute_string.stosb, 0, [rb + operation]
    add 0, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 1, 0, [rb + index_delta]
    add 0, 0, [rb + check_zf]

    jz  0, execute_string

execute_stos_w:
    arb -10

    add execute_string.stosw, 0, [rb + operation]
    add 0, 0, [rb + do_si]
    add 1, 0, [rb + do_di]
    add 2, 0, [rb + index_delta]
    add 0, 0, [rb + check_zf]

execute_string:
    # Make index delta negative if DF is set
    mul -2, [flag_direction], [rb + tmp]
    add 1, [rb + tmp], [rb + tmp]
    mul [rb + index_delta], [rb + tmp], [rb + index_delta]

    # Precalculate segment base addresses
    jz [rb + do_si], .after_src_seg

    add [ds_segment_prefix], 1, [ip + 1]
    mul [0], 0x100, [rb + src_seg]
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], [rb + src_seg], [rb + src_seg]

.after_src_seg:
    jz [rb + do_di], .after_dst_seg

    mul [reg_es + 1], 0x100, [rb + dst_seg]
    add [reg_es + 0], [rb + dst_seg], [rb + dst_seg]

.after_dst_seg:
    # Check for REPZ/REPNZ
    jz  [rep_prefix], .after_rep

.loop:
    # Stop if CX == 0
    add [reg_cx + 0], [reg_cx + 1], [rb + tmp]
    jz  [rb + tmp], .done

    # TODO process pending IRQs

    call dec_cx

.after_rep:
    jz [rb + do_si], .after_src_off

    # Calculate source offset
    mul [reg_si + 1], 0x100, [rb + src_off]
    add [reg_si + 0], [rb + src_off], [rb + src_off]

.after_src_off:
    jz [rb + do_di], .after_dst_off

    # Calculate destination offset
    mul [reg_di + 1], 0x100, [rb + dst_off]
    add [reg_di + 0], [rb + dst_off], [rb + dst_off]

.after_dst_off:
    # Execute the operation itself
    jz  0, [rb + operation]

.cmpsb:
    # Call execute_cmp_b with the two memory locations
    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add [rb + src_seg], 0, [rb - 3]
    add [rb + src_off], 0, [rb - 4]
    arb -4
    call execute_cmp_b

    jz  0, .after_operation

.cmpsw:
    # Call execute_cmp_w with the two memory locations
    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add [rb + src_seg], 0, [rb - 3]
    add [rb + src_off], 0, [rb - 4]
    arb -4
    call execute_cmp_w

    jz  0, .after_operation

.scasb:
    # Call execute_cmp_b with the memory and AL locations
    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add 0x10000, 0, [rb - 3]
    add reg_al, 0, [rb - 4]
    arb -4
    call execute_cmp_b

    jz  0, .after_operation

.scasw:
    # Call execute_cmp_w with the memory and AX locations
    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add 0x10000, 0, [rb - 3]
    add reg_ax, 0, [rb - 4]
    arb -4
    call execute_cmp_w

    jz  0, .after_operation

.lodsw:
    # Copy a word from source to AX
    add [rb + src_seg], 0, [rb - 1]
    add [rb + src_off], 0, [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [reg_ax + 0]
    add [rb - 5], 0, [reg_ax + 1]

    jz  0, .after_operation

.lodsb:
    # Copy a byte from source to AL
    add [rb + src_seg], 0, [rb - 1]
    add [rb + src_off], 0, [rb - 2]
    arb -2
    call read_seg_off_b
    add [rb - 4], 0, [reg_al]

    jz  0, .after_operation

.stosw:
    # Copy a word from AX to destination
    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add [reg_ax + 0], 0, [rb - 3]
    add [reg_ax + 1], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    jz  0, .after_operation

.stosb:
    # Copy a byte from AL to destination
    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add [reg_al], 0, [rb - 3]
    arb -3
    call write_seg_off_b

    jz  0, .after_operation

.movsw:
    # Copy a word from source to destination
    add [rb + src_seg], 0, [rb - 1]
    add [rb + src_off], 0, [rb - 2]
    arb -2
    call read_seg_off_w

    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]
    add [rb - 5], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    jz  0, .after_operation

.movsb:
    # Copy a byte from source to destination
    add [rb + src_seg], 0, [rb - 1]
    add [rb + src_off], 0, [rb - 2]
    arb -2
    call read_seg_off_b

    add [rb + dst_seg], 0, [rb - 1]
    add [rb + dst_off], 0, [rb - 2]
    add [rb - 4], 0, [rb - 3]
    arb -3
    call write_seg_off_b

.after_operation:
    # Are we incrementing or decrementing SI/DI?
    jz  [flag_direction], .increment

    jz  [rb + do_si], .decrement_si_done

    # Decrement SI
    add [reg_si + 0], [rb + index_delta], [reg_si + 0]

    # Check for borrow into low byte
    lt  [reg_si + 0], 0x00, [rb + tmp]
    jz  [rb + tmp], .decrement_si_done

    add [reg_si + 0], 0x100, [reg_si + 0]
    add [reg_si + 1], -1, [reg_si + 1]

    # Check for borrow into high byte
    lt  [reg_si + 1], 0x00, [rb + tmp]
    jz  [rb + tmp], .decrement_si_done

    add [reg_si + 1], 0x100, [reg_si + 1]

.decrement_si_done:
    jz  [rb + do_di], .after_si_di

    # Decrement DI
    add [reg_di + 0], [rb + index_delta], [reg_di + 0]

    # Check for borrow into low byte
    lt  [reg_di + 0], 0x00, [rb + tmp]
    jz  [rb + tmp], .after_si_di

    add [reg_di + 0], 0x100, [reg_di + 0]
    add [reg_di + 1], -1, [reg_di + 1]

    # Check for borrow into high byte
    lt  [reg_di + 1], 0x00, [rb + tmp]
    jz  [rb + tmp], .after_si_di

    add [reg_di + 1], 0x100, [reg_di + 1]

    jz  0, .after_si_di

.increment:
    jz  [rb + do_si], .increment_si_done

    # Increment SI
    add [reg_si + 0], [rb + index_delta], [reg_si + 0]

    # Check for carry out of low byte
    lt  [reg_si + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .increment_si_done

    add [reg_si + 0], -0x100, [reg_si + 0]
    add [reg_si + 1], 1, [reg_si + 1]

    # Check for carry out of high byte
    lt  [reg_si + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .increment_si_done

    add [reg_si + 1], -0x100, [reg_si + 1]

.increment_si_done:
    jz  [rb + do_di], .after_si_di

    # Increment DI
    add [reg_di + 0], [rb + index_delta], [reg_di + 0]

    # Check for carry out of low byte
    lt  [reg_di + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_si_di

    add [reg_di + 0], -0x100, [reg_di + 0]
    add [reg_di + 1], 1, [reg_di + 1]

    # Check for carry out of high byte
    lt  [reg_di + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], .after_si_di

    add [reg_di + 1], -0x100, [reg_di + 1]

.after_si_di:
    # If there is no REP prefix, we are done
    jz  [rep_prefix], .done

    # If we don't need to check ZF, loop
    jz  [rb + check_zf], .loop

    # Exit the loop if ZF does not match the REPZ/REPNZ prefix
    eq  [rep_prefix], '1', [rb + tmp]
    eq  [flag_zero], [rb + tmp], [rb + tmp]
    jnz [rb + tmp], .done

    jz  0, .loop

.done:
    arb 10
    ret 0
.ENDFRAME

.EOF
