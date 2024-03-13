.EXPORT immediate
.EXPORT zeropage
.EXPORT zeropage_x
.EXPORT zeropage_y
.EXPORT absolute
.EXPORT absolute_x
.EXPORT absolute_y
.EXPORT indirect8_x
.EXPORT indirect8_y
.EXPORT indirect16
.EXPORT relative

# From memory.s
.IMPORT read

# From state.s
.IMPORT inc_ip
.IMPORT reg_ip
.IMPORT reg_x
.IMPORT reg_y

# From util.s
.IMPORT mod

##########
immediate:
.FRAME addr                                         # addr is returned
    arb -1

    add [reg_ip], 0, [rb + addr]                    # [reg_ip] -> [addr]
    call inc_ip

    arb 1
    ret 0
.ENDFRAME

##########
.FRAME addr, reg                                    # addr is returned
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

zeropage:
    arb -2
    add 0, 0, [rb + reg]
    jz  0, zeropage_generic

zeropage_x:
    arb -2
    add [reg_x], 0, [rb + reg]
    jz  0, zeropage_generic

zeropage_y:
    arb -2
    add [reg_y], 0, [rb + reg]

zeropage_generic:
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + reg], [rb - 1]              # read([reg_ip]) + [reg] -> [param0]

    add 0x100, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + addr]                    # (read([reg_ip]) + [reg]) % 0x100 -> [addr]

    call inc_ip

    arb 2
    ret 0
.ENDFRAME

##########
.FRAME addr, reg                                    # addr is returned
    # Multiple entry points for this function, to share the common code without having to add
    # a parameter (which would not work with the exec.s instructions table mechanism).

absolute:
    arb -2
    add 0, 0, [rb + reg]
    jz  0, absolute_generic

absolute_x:
    arb -2
    add [reg_x], 0, [rb + reg]
    jz  0, absolute_generic

absolute_y:
    arb -2
    add [reg_y], 0, [rb + reg]

absolute_generic:
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + reg], [rb + addr]           # read([reg_ip]) + [reg] -> [addr]

    call inc_ip

    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    mul [rb - 3], 0x100, [rb - 1]                   # read([reg_ip]) * 0x100 -> [param0]
    add [rb - 1], [rb + addr], [rb - 1]             # [param0] + [addr] -> [param0]

    add 0x10000, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + addr]                    # (read([reg_ip]) + [reg] + read([reg_ip]) * 0x100) % 0x10000 -> [addr]

    call inc_ip

    arb 2
    ret 0
.ENDFRAME

# The two indirect8 modes are different:
# - indirect8_x increments the first address
# - indirect8_y increments the second address

##########
indirect8_x:
.FRAME addr, tmp                                    # addr is returned
    arb -2

    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [reg_x], [rb - 1]                 # read([reg_ip]) + [reg_x] -> [param0]

    add 0x100, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + tmp]                     # (read([reg_ip]) + [reg_x]) % 0x100 -> [tmp]

    call inc_ip

    add [rb + tmp], 1, [rb - 1]                     # [tmp] + 1 -> param0
    arb -1
    call read
    mul [rb - 3], 0x100, [rb + addr]                # read([tmp] + 1) * 0x100 -> [addr]

    add [rb + tmp], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + addr], [rb + addr]          # read([tmp]) + read([tmp] + 1) * 0x100 -> [addr]

    arb 2
    ret 0
.ENDFRAME

##########
indirect8_y:
.FRAME addr, tmp                                    # addr is returned
    arb -2

    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + tmp]                     # read([reg_ip]) -> [tmp]

    call inc_ip

    add [rb + tmp], 1, [rb - 1]                     # [tmp] + 1 -> param0
    arb -1
    call read
    mul [rb - 3], 0x100, [rb + addr]                # read([tmp] + 1) * 0x100 -> [addr]

    add [rb + tmp], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + addr], [rb + addr]          # read([tmp]) + read([tmp] + 1) * 0x100 -> [addr]
    add [rb + addr], [reg_y], [rb - 1]              # read([tmp]) + read([tmp] + 1) * 0x100 + [reg_y] -> [param0]

    add 0x10000, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + addr]                    # (read([tmp]) + read([tmp] + 1) * 0x100 + [reg_y]) % 0x10000 -> [addr]

    arb 2
    ret 0
.ENDFRAME

##########
indirect16:
.FRAME addr, lo, hi                                 # addr is returned
    arb -3

    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + lo]                      # read([reg_ip]) -> [lo]

    call inc_ip

    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + hi]                      # read([reg_ip]) -> [hi]

    call inc_ip

    # Special way of incrementing the address to get the second byte:
    # Increment the low byte without carry to the high byte

    mul [rb + hi], 0x100, [rb + hi]                 # [hi] * 0x100 -> [hi]
    add [rb + lo], 1, [rb - 1]                      # [lo] + 1 -> [param0]
    add [rb + hi], [rb + lo], [rb + lo]             # [hi] + [lo] -> [lo]

    add 0x100, 0, [rb - 2]
    arb -2
    call mod
    add [rb + hi], [rb - 4], [rb + hi]              # [hi] + ([lo] + 1) % 0x100 -> [hi]

    # Second indirection

    add [rb + hi], 0, [rb - 1]
    arb -1
    call read
    mul [rb - 3], 0x100, [rb + addr]                # read([hi]) * 0x100 -> [addr]

    add [rb + lo], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], [rb + addr], [rb + addr]          # read([lo]) + read([hi]) * 0x100 -> [addr]

    arb 3
    ret 0
.ENDFRAME

##########
relative:
.FRAME addr, tmp                                    # addr is returned
    arb -2

    add [reg_ip], 0, [rb - 1]
    arb -1
    call read
    add [rb - 3], 0, [rb + addr]                    # read([reg_ip]) -> [addr]

    call inc_ip

    lt  [rb + addr], 0x80, [rb + tmp]
    jnz [rb + tmp], relative_offset_ready

    # Negative offset for 0x80-0xff
    add [rb + addr], -0x100, [rb + addr]

relative_offset_ready:
    add [reg_ip], [rb + addr], [rb - 1]             # [reg_ip] + [addr] -> [param0]

    add 0x10000, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + addr]                    # ([reg_ip] + [addr]) % 0x10000 -> [addr]

    arb 2
    ret 0
.ENDFRAME

.EOF
