.EXPORT read_seg_off_b
.EXPORT read_seg_off_w
.EXPORT read_seg_off_dw

.EXPORT write_seg_off_b
.EXPORT write_seg_off_w

.EXPORT read_cs_ip_b
.EXPORT read_cs_ip_w

# From regions.s
.IMPORT read_memory_b
.IMPORT write_memory_b

# From state.s
.IMPORT reg_cs
.IMPORT reg_ip

# TODO optimize and inline calc_addr_w

##########
calc_addr_w:
.FRAME seg, off; addr_lo, addr_hi, off_hi, tmp              # returns addr_lo, addr_hi
    arb -4

    # TODO optimize the common case when off != 0xffff and addr_lo != 0xfffff

    # Calculate physical address of the lo byte
    mul [rb + seg], 0x10, [rb + addr_lo]
    add [rb + off], [rb + addr_lo], [rb + addr_lo]

    # Wrap around address of lo byte to 20 bits
    lt  [rb + addr_lo], 0x100000, [rb + tmp]
    jnz [rb + tmp], .addr_lo_done

    add [rb + addr_lo], -0x100000, [rb + addr_lo]

.addr_lo_done:
    # Increment offset with wrap around to 16 bits
    add [rb + off], 1, [rb + off_hi]

    lt  [rb + off_hi], 0x10000, [rb + tmp]
    jnz [rb + tmp], .off_hi_done

    add [rb + off_hi], -0x10000, [rb + off_hi]

.off_hi_done:
    # Calculate physical address of the hi byte
    mul [rb + seg], 0x10, [rb + addr_hi]
    add [rb + off_hi], [rb + addr_hi], [rb + addr_hi]

    # Wrap around address of hi byte to 20 bits
    lt  [rb + addr_hi], 0x100000, [rb + tmp]
    jnz [rb + tmp], .addr_hi_done

    add [rb + addr_hi], -0x100000, [rb + addr_hi]

.addr_hi_done:
    arb 4
    ret 2
.ENDFRAME

##########
read_cs_ip_b:
.FRAME value                                                # returns value
    arb -1

    # 32107654321076543210
    # |cs__hi||cs__lo|
    #     |ip__hi||ip__lo|

    # Calculate the physical address
    mul [reg_cs + 1], 0x10, [rb - 1]
    add [reg_ip + 1], [rb - 1], [rb - 1]
    mul [rb - 1], 0x10, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    mul [rb - 1], 0x10, [rb - 1]
    add [reg_ip + 0], [rb - 1], [rb - 1]

    # Wrap around to 20 bits
    lt  [rb - 1], 0x100000, [rb - 2]
    jnz [rb - 2], .after_mod

    add [rb - 1], -0x100000, [rb - 1]

.after_mod:
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value]

    arb 1
    ret 0
.ENDFRAME

##########
read_cs_ip_w:
.FRAME value_lo, value_hi, addr_lo, addr_hi                 # returns value_lo, value_hi
    arb -4

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    mul [reg_ip + 1], 0x100, [rb - 2]
    add [reg_ip + 0], [rb - 2], [rb - 2]
    arb -2
    call calc_addr_w
    add [rb - 4], 0, [rb + addr_lo]
    add [rb - 5], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_hi]

    arb 4
    ret 0
.ENDFRAME

##########
read_seg_off_b:
.FRAME seg, off; value                                      # returns value
    arb -1

    # 32107654321076543210
    # |-----seg------|
    #     |-----off------|

    # Calculate the physical address
    mul [rb + seg], 0x10, [rb - 1]
    add [rb + off], [rb - 1], [rb - 1]

    # Wrap around to 20 bits
    lt  [rb - 1], 0x100000, [rb - 2]
    jnz [rb - 2], .after_mod

    add [rb - 1], -0x100000, [rb - 1]

.after_mod:
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value]

    arb 1
    ret 2
.ENDFRAME

##########
read_seg_off_w:
.FRAME seg, off; value_lo, value_hi, addr_lo, addr_hi       # returns value_lo, value_hi
    arb -4

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_w
    add [rb - 4], 0, [rb + addr_lo]
    add [rb - 5], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_hi]

    arb 4
    ret 2
.ENDFRAME

##########
read_seg_off_dw:
.FRAME seg, off; value_ll, value_lh, value_hl, value_hh, addr_lo, addr_hi, tmp                      # returns value_*
    arb -7

    # Read the lo word
    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_w
    add [rb - 4], 0, [rb + addr_lo]
    add [rb - 5], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_ll]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_lh]

    # Calculate offset of the hi word
    # TODO separate algorithm to calculate the double word addressess
    add [rb + off], 2, [rb + off]

    lt  [rb + off], 0x10000, [rb + tmp]
    jnz [rb + tmp], .hi_word_offset_done

    add [rb + off], -0x10000, [rb + off]

.hi_word_offset_done:
    # Read the hi word
    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_w
    add [rb - 4], 0, [rb + addr_lo]
    add [rb - 5], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_hl]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_memory_b
    add [rb - 3], 0, [rb + value_hh]

    arb 7
    ret 2
.ENDFRAME

##########
write_seg_off_b:
.FRAME seg, off, value;
    # 32107654321076543210
    # |-----seg------|
    #     |-----off------|

    # Calculate the physical address
    mul [rb + seg], 0x10, [rb - 1]
    add [rb + off], [rb - 1], [rb - 1]

    # Wrap around to 20 bits
    lt  [rb - 1], 0x100000, [rb - 2]
    jnz [rb - 2], .after_mod

    add [rb - 1], -0x100000, [rb - 1]

.after_mod:
    add [rb + value], 0, [rb - 2]
    arb -2
    call write_memory_b

    ret 3
.ENDFRAME

##########
write_seg_off_w:
.FRAME seg, off, value_lo, value_hi; addr_lo, addr_hi
    arb -2

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_w
    add [rb - 4], 0, [rb + addr_lo]
    add [rb - 5], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    add [rb + value_lo], 0, [rb - 2]
    arb -2
    call write_memory_b

    add [rb + addr_hi], 0, [rb - 1]
    add [rb + value_hi], 0, [rb - 2]
    arb -2
    call write_memory_b

    arb 2
    ret 4
.ENDFRAME

.EOF
