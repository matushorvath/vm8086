.EXPORT calc_addr_b
.EXPORT calc_addr_w

.EXPORT calc_cs_ip_addr_b
.EXPORT calc_cs_ip_addr_w

.EXPORT read_b
.EXPORT write_b

.EXPORT read_cs_ip_b
.EXPORT read_cs_ip_w

#.EXPORT push
#.EXPORT pop

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
calc_cs_ip_addr_b:
.FRAME addr, tmp                                            # returns addr
    arb -2

    # TODO this address should not be used to read word-sized values

    #      3210|7654 3210|7654 3210
    # cs = ---csh--- ---csl---
    # ip =      ---iph--- ---ipl---
    #
    # addr = (((csh << 4) + iph) << 4 + csl) << 4 + ipl;

    # Calculate the physical address
    mul [reg_cs + 1], 0x10, [rb + addr]
    add [reg_ip + 1], [rb + addr], [rb + addr]
    mul [rb + addr], 0x10, [rb + addr]
    add [reg_cs + 0], [rb + addr], [rb + addr]
    mul [rb + addr], 0x10, [rb + addr]
    add [reg_ip + 0], [rb + addr], [rb + addr]

    # Wrap around to 20 bits
    lt  [rb + addr], 0x100000, [rb + tmp]
    jnz [rb + tmp], calc_cs_ip_addr_b_done

    add [rb + addr], -0x100000, [rb + addr]

calc_cs_ip_addr_b_done:
    arb 2
    ret 0
.ENDFRAME

##########
calc_cs_ip_addr_w:
.FRAME addr_lo, addr_hi, off_hi, tmp                        # returns addr_lo, addr_hi
    arb -4

    # TODO optimize the common case when reg_ip != 0xffff and addr_lo != 0xfffff

    #      3210|7654 3210|7654 3210
    # cs = ---csh--- ---csl---
    # ip =      ---iph--- ---ipl---
    #
    # addr_lo = (((csh << 4) + iph) << 4 + csl) << 4 + ipl;

    # Calculate physical address of the lo byte
    mul [reg_cs + 1], 0x10, [rb + addr_lo]
    add [reg_ip + 1], [rb + addr_lo], [rb + addr_lo]
    mul [rb + addr_lo], 0x10, [rb + addr_lo]
    add [reg_cs + 0], [rb + addr_lo], [rb + addr_lo]
    mul [rb + addr_lo], 0x10, [rb + addr_lo]
    add [reg_ip + 0], [rb + addr_lo], [rb + addr_lo]

    # Wrap around address of lo byte to 20 bits
    lt  [rb + addr_lo], 0x100000, [rb + tmp]
    jnz [rb + tmp], calc_cs_ip_addr_w_addr_lo_done

    add [rb + addr_lo], -0x100000, [rb + addr_lo]

calc_cs_ip_addr_w_addr_lo_done:
    # Increment ip with wrap around to 16 bits, store in off_hi
    mul [reg_ip + 1], 0x100, [rb + off_hi]
    add [reg_ip + 0], [rb + off_hi], [rb + off_hi]

    lt  [rb + off_hi], 0x10000, [rb + tmp]
    jnz [rb + tmp], calc_cs_ip_addr_w_off_hi_done

    add [rb + off_hi], -0x10000, [rb + off_hi]

calc_cs_ip_addr_w_off_hi_done:
    #          3210|7654 3210|7654 3210
    # cs     = ---csh--- ---csl---
    # off_hi =      ------off_hi-------
    #
    # addr_hi = ((csh << 8) + csl) << 4 + off_hi;

    # Calculate physical address of the hi byte
    mul [reg_cs + 1], 0x100, [rb + addr_hi]
    add [reg_cs + 0], [rb + addr_hi], [rb + addr_hi]
    mul [rb + addr_hi], 0x10, [rb + addr_hi]
    add [rb + off_hi], [rb + addr_hi], [rb + addr_hi]

    # Wrap around address of hi byte to 20 bits
    lt  [rb + addr_hi], 0x100000, [rb + tmp]
    jnz [rb + tmp], calc_cs_ip_addr_w_addr_hi_done

    add [rb + addr_hi], -0x100000, [rb + addr_hi]

calc_cs_ip_addr_w_addr_hi_done:
    arb 4
    ret 0
.ENDFRAME

##########
read_cs_ip_b:
.FRAME value, addr                                          # returns value
    arb -2

    call calc_cs_ip_addr_b
    add [rb - 2], 0, [rb + addr]

    add [rb + addr], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value]

    arb 2
    ret 0
.ENDFRAME

##########
read_cs_ip_w:
.FRAME value_lo, value_hi, addr_lo, addr_hi                 # returns value_lo, value_hi
    arb -4

    call calc_cs_ip_addr_w
    add [rb - 2], 0, [rb + addr_lo]
    add [rb - 3], 0, [rb + addr_hi]

    add [rb + addr_lo], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_lo]

    add [rb + addr_hi], 1, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + value_hi]

    arb 4
    ret 0
.ENDFRAME

.EOF
