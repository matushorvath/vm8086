.EXPORT push_w
.EXPORT pop_w

.EXPORT pushf
.EXPORT popf

# From flags.s
.IMPORT pack_flags_lo
.IMPORT pack_flags_hi
.IMPORT unpack_flags_lo
.IMPORT unpack_flags_hi

# From memory.s
.IMPORT read_seg_off_w
.IMPORT write_seg_off_w

# From state.s
.IMPORT reg_ss
.IMPORT reg_sp

##########
# Increment sp by 2 with wrap around
inc_2_sp:
.FRAME tmp
    arb -1

    # Increment the low byte
    add [reg_sp + 0], 2, [reg_sp + 0]

    # Check for carry out of low byte
    lt  [reg_sp + 0], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_2_sp_done

    add [reg_sp + 0], -0x100, [reg_sp + 0]
    add [reg_sp + 1], 1, [reg_sp + 1]

    # Check for carry out of high byte
    lt  [reg_sp + 1], 0x100, [rb + tmp]
    jnz [rb + tmp], inc_2_sp_done

    # Overflow
    add [reg_sp + 1], -0x100, [reg_sp + 1]

inc_2_sp_done:
    arb 1
    ret 0
.ENDFRAME

##########
# Decrement sp by 2 with wrap around
dec_2_sp:
.FRAME tmp
    arb -1

    # Decrement the low byte
    add [reg_sp + 0], -2, [reg_sp + 0]

    # Check for borrow into low byte
    lt  [reg_sp + 0], 0, [rb + tmp]
    jz  [rb + tmp], dec_2_sp_done

    add [reg_sp + 0], 0x100, [reg_sp + 0]
    add [reg_sp + 1], -1, [reg_sp + 1]

    # Check for borrow into high byte
    lt  [reg_sp + 1], 0, [rb + tmp]
    jz  [rb + tmp], dec_2_sp_done

    # Underflow
    add [reg_sp + 1], 0x100, [reg_sp + 1]

dec_2_sp_done:
    arb 1
    ret 0
.ENDFRAME

##########
push_w:
.FRAME value_lo, value_hi;
    # Decrement sp by 2
    call dec_2_sp

    # Store the value
    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 2], [rb - 2]
    add [rb + value_lo], 0, [rb - 3]
    add [rb + value_hi], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    ret 2
.ENDFRAME

##########
pop_w:
.FRAME value_lo, value_hi                                   # returns value_lo, value_hi
    arb -2

    # Read the value
    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 2], [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [rb + value_lo]
    add [rb - 5], 0, [rb + value_hi]

    # Increment sp by 2
    call inc_2_sp

    arb 2
    ret 0
.ENDFRAME

##########
pushf:
.FRAME flags_lo, flags_hi
    arb -2

    # Decrement sp by 2
    call dec_2_sp

    # Pack the flags
    call pack_flags_lo
    add [rb - 2], 0, [rb + flags_lo]

    call pack_flags_hi
    add [rb - 2], 0, [rb + flags_hi]

    # Store the value
    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 2], [rb - 2]
    add [rb + flags_lo], 0, [rb - 3]
    add [rb + flags_hi], 0, [rb - 4]
    arb -4
    call write_seg_off_w

    arb 2
    ret 0
.ENDFRAME

##########
popf:
.FRAME flags_lo, flags_hi
    arb -2

    # Read the value
    mul [reg_ss + 1], 0x100, [rb - 1]
    add [reg_ss + 0], [rb - 1], [rb - 1]
    mul [reg_sp + 1], 0x100, [rb - 2]
    add [reg_sp + 0], [rb - 2], [rb - 2]
    arb -2
    call read_seg_off_w
    add [rb - 4], 0, [rb + flags_lo]
    add [rb - 5], 0, [rb + flags_hi]

    # Increment sp by 2
    call inc_2_sp

    # Unpack the flags
    add [rb + flags_lo], 0, [rb - 1]
    arb -1
    call unpack_flags_lo

    add [rb + flags_hi], 0, [rb - 1]
    arb -1
    call unpack_flags_hi

    arb 2
    ret 0
.ENDFRAME

.EOF
