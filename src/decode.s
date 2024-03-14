.EXPORT decode_mod_rm

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT read_b
.IMPORT read_w

# From split233.s
.IMPORT split233

# From state.s
.IMPORT reg_ax
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_dx

.IMPORT reg_al
.IMPORT reg_bl
.IMPORT reg_cl
.IMPORT reg_dl

.IMPORT reg_ah
.IMPORT reg_bh
.IMPORT reg_ch
.IMPORT reg_dh

.IMPORT reg_bp
.IMPORT reg_sp
.IMPORT reg_si
.IMPORT reg_di

.IMPORT reg_ds
.IMPORT reg_ss

.IMPORT reg_ip
.IMPORT inc_ip

# loc_type: 0
# loc_addr: intcode address of an 8086 register
#
# loc_type: 1
# loc_addr: 8086 physical memory address

##########
decode_mod_rm:
.FRAME w; loc_type, loc_addr, mod, reg, rm, disp, tmp       # return loc_type, loc_addr
    arb -7

    # Read the MOD REG R/M byte and split it
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read_b
    mul [rb - 3], 3, [rb + tmp]

    call inc_ip

    add split233 + 0, [rb + tmp], [rb + rm]
    add split233 + 1, [rb + tmp], [rb + reg]
    add split233 + 2, [rb + tmp], [rb + mod]

    # Decode the mod field
    add decode_mod_rm_mod_table, [rb + rm], [ip + 2]
    jz  0, [0]

decode_mod_rm_mod_table:
    # Map each MOD value to the label that handles it
    db  decode_mod_rm_mem_mod00
    db  decode_mod_rm_mem_disp8
    db  decode_mod_rm_mem_disp16
    db  decode_mod_rm_reg

decode_mod_rm_mem_mod00:
    # Memory mode, no displacement; except when R/M is 0b110, then 16-bit displacement follows
    eq  [rb + rm], 0x110, [rb + tmp]
    jz  [rb + tmp], decode_mod_rm_mem_no_disp

    # Handle the special case with a fake R/M value of 0x1000
    add 0x1000, 0, [rb + rm]
    jz  0, decode_mod_rm_mem_disp16

decode_mod_rm_mem_no_disp:
    # Memory mode with no displacement
    add 0, 0, [rb + disp]

    # Jump to handling of this R/M value
    add decode_mod_rm_mem_table, [rb + rm], [ip + 2]
    jz  0, [0]

decode_mod_rm_mem_disp8:
    # Memory mode with 8-bit displacement

    # Read 8-bit displacement
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read_b
    add [rb - 3], 0, [rb + disp]

    call inc_ip

    # Sign extend the displacement
    lt  [rb + disp], 0x80, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_disp8_positive

    add [rb + disp], 0xff00, [rb + disp]

decode_mod_rm_mem_disp8_positive:
    # Jump to handling of this R/M value
    add decode_mod_rm_mem_table, [rb + rm], [ip + 2]
    jz  0, [0]

decode_mod_rm_mem_disp16:
    # Memory mode with 16-bit displacement

    # Read 16-bit displacement
    add [reg_ip], 0, [rb - 1]
    arb -1
    call read_w
    mul [rb - 4], 0xff, [rb + disp]
    add [rb + disp], [rb - 3], [rb + disp]

    call inc_ip
    call inc_ip

    # Jump to handling of this R/M value
    add decode_mod_rm_mem_table, [rb + rm], [ip + 2]
    jz  0, [0]

decode_mod_rm_mem_table:
    # Map each R/M value to the label that handles it
    db  decode_mod_rm_memory_bx_si
    db  decode_mod_rm_memory_bx_di
    db  decode_mod_rm_memory_bp_si
    db  decode_mod_rm_memory_bp_di
    db  decode_mod_rm_memory_si
    db  decode_mod_rm_memory_di
    db  decode_mod_rm_memory_bp
    db  decode_mod_rm_memory_bx
    db  decode_mod_rm_memory_direct

decode_mod_rm_memory_bx_si:
    add [reg_bx + 1], [reg_si + 1], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ds], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_bx + 0], [rb + loc_addr]
    add [rb + loc_addr], [reg_si + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bx_di:
    add [reg_bx + 1], [reg_di + 1], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ds], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_bx + 0], [rb + loc_addr]
    add [rb + loc_addr], [reg_di + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bp_si:
    add [reg_bp + 1], [reg_si + 1], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ss], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_bp + 0], [rb + loc_addr]
    add [rb + loc_addr], [reg_si + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bp_di:
    add [reg_bp + 1], [reg_di + 1], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ss], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_bp + 0], [rb + loc_addr]
    add [rb + loc_addr], [reg_di + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_si:
    mul [reg_si + 1], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ds], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_si + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_di:
    mul [reg_di + 1], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ds], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_di + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bp:
    mul [reg_bp + 1], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ss], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_bp + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bx:
    mul [reg_bx + 1], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_ds], [rb + loc_addr]
    mul [rb + loc_addr], 0xf, [rb + loc_addr]
    add [rb + loc_addr], [reg_bx + 0], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_direct:
    mul [reg_ds], 0xf, [rb + loc_addr]
    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_reg:
    # Register mode, no displacement
    add 1, 0, [rb + loc_type]                               # return an intcode address of an 8086 register

    # Jump to handling of this R/M value
    mul [rb + w], 2, [rb + tmp]
    add [rb + tmp], [rb + rm], [rb + tmp]
    add decode_mod_rm_reg_table, [rb + tmp], [ip + 2]
    jz  0, [0]

decode_mod_rm_reg_table:
    # Map each R/M value to the label that handles it
    db  decode_mod_rm_reg_al
    db  decode_mod_rm_reg_cl
    db  decode_mod_rm_reg_dl
    db  decode_mod_rm_reg_bl
    db  decode_mod_rm_reg_ah
    db  decode_mod_rm_reg_ch
    db  decode_mod_rm_reg_dh
    db  decode_mod_rm_reg_bh

    db  decode_mod_rm_reg_ax
    db  decode_mod_rm_reg_cx
    db  decode_mod_rm_reg_dx
    db  decode_mod_rm_reg_bx
    db  decode_mod_rm_reg_sp
    db  decode_mod_rm_reg_bp
    db  decode_mod_rm_reg_si
    db  decode_mod_rm_reg_di

decode_mod_rm_reg_al:
    add reg_al, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_cl:
    add reg_cl, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_dl:
    add reg_dl, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bl:
    add reg_bl, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_ah:
    add reg_ah, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_ch:
    add reg_ch, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_dh:
    add reg_dh, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bh:
    add reg_bh, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_ax:
    add reg_ax, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_cx:
    add reg_cx, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_dx:
    add reg_dx, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bx:
    add reg_bx, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_sp:
    add reg_sp, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bp:
    add reg_bp, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_si:
    add reg_si, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_di:
    add reg_di, 0, [rb + loc_addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_mem_calc:
    # Finish calculating the 8086 physical memory address
    add 1, 0, [rb + loc_type]                               # return an 8086 memory address

    # Add displacement and wrap around to 20 bits
    add [rb + loc_addr], [rb + disp], [rb - 1]
    add 0x100000, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], 0, [rb + loc_addr]

decode_mod_rm_end:
    arb 7
    ret 1

decode_mod_rm_invalid_message:
    db  "invalid instruction while decoding MOD REG R/M", 0

.ENDFRAME

.EOF
