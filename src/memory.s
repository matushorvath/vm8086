.EXPORT read_b
.EXPORT write_b

.EXPORT read_seg_off_b
.EXPORT read_seg_off_w
.EXPORT read_seg_off_dw

.EXPORT write_seg_off_b
.EXPORT write_seg_off_w

.EXPORT read_cs_ip_b
.EXPORT read_cs_ip_w

# From state.s
.IMPORT mem
.IMPORT reg_cs
.IMPORT reg_ip

##########
read_b:
.FRAME addr; value                                          # returns value
    arb -1

    # TODO support memory mapped IO

    # Regular memory read
    add [mem], [rb + addr], [ip + 1]
    add [0], 0, [rb + value]

    arb 1
    ret 1
.ENDFRAME

##########
write_b:
.FRAME addr, value;
    # TODO support memory mapped IO
    # TODO handle not being able to write to ROM

    # Regular memory write
    add [mem], [rb + addr], [ip + 3]
    add [rb + value], 0, [0]

    ret 2
.ENDFRAME

##########
calc_addr_b:
.FRAME seg, off; addr, tmp                                  # returns addr
    arb -2

    # Calculate the physical address
    mul [rb + seg], 0x10, [rb + addr]
    add [rb + off], [rb + addr], [rb + addr]

    # Wrap around to 20 bits
    lt  [rb + addr], 0x100000, [rb + tmp]
    jnz [rb + tmp], calc_addr_b_done

    add [rb + addr], -0x100000, [rb + addr]

calc_addr_b_done:
    arb 2
    ret 2
.ENDFRAME

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
    jnz [rb + tmp], calc_addr_w_addr_lo_done

    add [rb + addr_lo], -0x100000, [rb + addr_lo]

calc_addr_w_addr_lo_done:
    # Increment offset with wrap around to 16 bits
    add [rb + off], 1, [rb + off_hi]

    lt  [rb + off_hi], 0x10000, [rb + tmp]
    jnz [rb + tmp], calc_addr_w_off_hi_done

    add [rb + off_hi], -0x10000, [rb + off_hi]

calc_addr_w_off_hi_done:
    # Calculate physical address of the hi byte
    mul [rb + seg], 0x10, [rb + addr_hi]
    add [rb + off_hi], [rb + addr_hi], [rb + addr_hi]

    # Wrap around address of hi byte to 20 bits
    lt  [rb + addr_hi], 0x100000, [rb + tmp]
    jnz [rb + tmp], calc_addr_w_addr_hi_done

    add [rb + addr_hi], -0x100000, [rb + addr_hi]

calc_addr_w_addr_hi_done:
    arb 4
    ret 2
.ENDFRAME

##########
read_cs_ip_b:
.FRAME value                                                # returns value
    arb -1

    mul [reg_cs + 1], 0x100, [rb - 1]
    add [reg_cs + 0], [rb - 1], [rb - 1]
    mul [reg_ip + 1], 0x100, [rb - 2]
    add [reg_ip + 0], [rb - 2], [rb - 2]
    arb -2
    call calc_addr_b

    add [rb - 4], 0, [rb - 1]
    arb -1
    call read_b
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
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hi]

    arb 4
    ret 0
.ENDFRAME

##########
read_seg_off_b:
.FRAME seg, off; value                                      # returns value
    arb -1

    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_b

    add [rb - 4], 0, [rb - 1]
    arb -1
    call read_b
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
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_b
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
    call read_b
    add [rb - 3], 0, [rb + value_ll]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_lh]

    # Calculate offset of the hi word
    # TODO separate algorithm to calculate the double word addressess
    add [rb + off], 2, [rb + off]

    lt  [rb + off], 0x10000, [rb + tmp]
    jnz [rb + tmp], read_seg_off_dw_hi_word_offset_done

    add [rb + off], -0x10000, [rb + off]

read_seg_off_dw_hi_word_offset_done:
    # Read the hi word
    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_w
    add [rb - 4], 0, [rb + addr_lo]
    add [rb - 5], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hl]

    add [rb + addr_hi], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hh]

    arb 7
    ret 2
.ENDFRAME

##########
write_seg_off_b:
.FRAME seg, off, value;
    add [rb + seg], 0, [rb - 1]
    add [rb + off], 0, [rb - 2]
    arb -2
    call calc_addr_b

    add [rb - 4], 0, [rb - 1]
    add [rb + value], 0, [rb - 2]
    arb -2
    call write_b

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
    call write_b

    add [rb + addr_hi], 0, [rb - 1]
    add [rb + value_hi], 0, [rb - 2]
    arb -2
    call write_b

    arb 2
    ret 4
.ENDFRAME

.EOF
