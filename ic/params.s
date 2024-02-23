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

# From state.s
.IMPORT reg_pc
.IMPORT reg_x
.IMPORT reg_y

# From util.s
.IMPORT incpc
.IMPORT mod_8bit
.IMPORT mod_16bit

##########
immediate:
.FRAME addr                                         # addr is returned
    arb -1

    add [reg_pc], 0, [rb + addr]                    # [reg_pc] -> [addr]
    call incpc

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
    add MEM, [reg_pc], [ip + 1]
    add [0], [rb + reg], [rb - 1]                   # [MEM + [reg_pc]] + [reg] -> [param0]

    arb -1
    call mod_8bit
    add [rb - 3], 0, [rb + addr]                    # ([MEM + [reg_pc]] + [reg]) % 0x100 -> [addr]

    call incpc

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
    add MEM, [reg_pc], [ip + 1]
    add [0], [rb + reg], [rb + addr]                # [MEM + [reg_pc]] + [reg] -> [addr]

    call incpc

    add MEM, [reg_pc], [ip + 1]
    mul [0], 256, [rb - 1]                          # [MEM + [reg_pc]] * 0x100 -> [param0]
    add [rb - 1], [rb + addr], [rb - 1]             # [param0] + [addr] -> [param0]

    arb -1
    call mod_16bit
    add [rb - 3], 0, [rb + addr]                    # ([MEM + [reg_pc]] + [reg] + [MEM + [reg_pc]] * 0x100) % 0x10000 -> [addr]

    call incpc

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

    add MEM, [reg_pc], [ip + 1]
    add [0], [reg_x], [rb - 1]                      # [MEM + [reg_pc]] + [reg_x] -> [param0]

    arb -1
    call mod_8bit
    add [rb - 3], 0, [rb + tmp]                     # ([MEM + [reg_pc]] + [reg_x]) % 0x100 -> [tmp]

    call incpc

    add MEM, [rb + tmp], [ip + 1]
    add [0], 1, [rb + addr]                         # [MEM + [tmp] + 1] -> [addr]
    mul [rb + addr], 256, [rb + addr]               # [MEM + [tmp] + 1] * 0x100 -> [addr]

    add MEM, [rb + tmp], [ip + 1]
    add [0], [rb + addr], [rb + addr]               # [MEM + [tmp]] + [addr] -> [addr]

    arb 2
    ret 0
.ENDFRAME

##########
indirect8_y:
.FRAME addr, tmp                                    # addr is returned
    arb -2

    add MEM, [reg_pc], [ip + 1]
    add [0], 0, [rb + tmp]                          # [MEM + [reg_pc]] -> [tmp]

    call incpc

    add MEM, [rb + tmp], [ip + 1]
    add [0], 1, [rb - 1]                            # [MEM + [tmp] + 1] -> [param0]
    mul [rb - 1], 256, [rb - 1]                     # [MEM + [tmp] + 1] * 0x100 -> [param0]

    add MEM, [rb + tmp], [ip + 1]
    add [0], [rb - 1], [rb - 1]                     # [MEM + [tmp]] + [param0] -> [param0]
    add [rb - 1], [reg_y], [rb - 1]                 # [param0] + [reg_y] -> [param0]

    arb -1
    call mod_16bit
    add [rb - 3], 0, [rb + addr]                    # ([MEM + [tmp]] + [MEM + [tmp] + 1] * 0x100 + [reg_y]) % 0x10000 -> [addr]

    arb 2
    ret 0
.ENDFRAME

##########
indirect16:
.FRAME addr, lo, hi                                 # addr is returned
    arb -3

    add MEM, [reg_pc], [ip + 1]
    add [0], 0, [rb + lo]                           # [MEM + [reg_pc]] -> [lo]

    call incpc

    add MEM, [reg_pc], [ip + 1]
    add [0], 0, [rb + hi]                           # [MEM + [reg_pc]] -> [hi]

    call incpc

    # Special way of incrementing the address to get the second byte:
    # Increment the low byte without carry to the high byte

    mul [rb + hi], 256, [rb + hi]                   # [hi] * 0x100 -> [hi]
    add [rb + lo], 1, [rb - 1]                      # [lo] + 1 -> [param0]
    add [rb + hi], [rb + lo], [rb + lo]             # [hi] + [lo] -> [lo]

    arb -1
    call mod_8bit
    add [rb + hi], [rb - 3], [rb + hi]              # [hi] + ([lo] + 1) % 256 -> [hi]

    # Second indirection

    add MEM, [rb + hi], [ip + 1]
    mul [0], 256, [rb + addr]                       # [MEM + [hi]] * 0x100 -> [addr]

    add MEM, [rb + lo], [ip + 1]
    add [0], [rb + addr], [rb + addr]               # [MEM + [lo]] + [MEM + [hi]] * 0x100 -> [addr]

    arb 3
    ret 0
.ENDFRAME

##########
relative:
.FRAME addr, tmp                                    # addr is returned
    arb -2

    add MEM, [reg_pc], [ip + 1]
    add [0], 0, [rb + addr]                         # [MEM + [reg_pc]] -> [addr]

    call incpc

    lt  [rb + addr], 128, [rb + tmp]
    jnz [rb + tmp], relative_offset_ready

    # Negative offset for 0x80-0xff
    add [rb + addr], -256, [rb + addr]

relative_offset_ready:
    add [reg_pc], [rb + addr], [rb - 1]             # [reg_pc] + [addr] -> [param0]

    arb -1
    call mod_16bit
    add [rb - 3], 0, [rb + addr]                    # ([reg_pc] + [addr]) % 0x10000 -> [addr]

    arb 2
    ret 0
.ENDFRAME

.EOF
