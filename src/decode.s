.EXPORT decode_mod_rm
.EXPORT decode_reg
.EXPORT decode_sr

# From error.s
.IMPORT report_error

# From memory.s
.IMPORT read_cs_ip_b
.IMPORT read_cs_ip_w

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

.IMPORT reg_cs
.IMPORT reg_ds
.IMPORT reg_ss
.IMPORT reg_es

.IMPORT inc_ip

# From util.s
.IMPORT modulo

##########
decode_mod_rm:
.FRAME mod, rm, w; loc_type, loc_addr, disp, tmp       # return loc_type, loc_addr
    arb -4

    # Decode the mod field
    add decode_mod_rm_mod_table, [rb + mod], [ip + 2]
    jz  0, [0]

decode_mod_rm_mod_table:
    # Map each MOD value to the label that handles it
    db  decode_mod_rm_mem_mod00
    db  decode_mod_rm_mem_disp8
    db  decode_mod_rm_mem_disp16
    db  decode_mod_rm_reg

decode_mod_rm_mem_mod00:
    # Memory mode, no displacement; except when R/M is 0b110, then 16-bit displacement follows
    eq  [rb + rm], 0b110, [rb + tmp]
    jz  [rb + tmp], decode_mod_rm_mem_no_disp

    # Handle the special case with a fake R/M value of 0b1000
    add 0b1000, 0, [rb + rm]
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
    call read_cs_ip_b
    add [rb - 2], 0, [rb + disp]

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
    call read_cs_ip_w
    mul [rb - 3], 0x100, [rb + disp]
    add [rb - 2], [rb + disp], [rb + disp]

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
    # Calculations below work like this:
    # loc_addr = (ds << 4) + bx + si
    #
    #      3210|7654 3210|7654 3210
    # ds = ---dsh--- ---dsl---
    # bx =      ---bxh--- ---bxl---
    # si =      ---sih--- ---sil---
    #
    # loc_addr = (((dsh << 4) + bxh + sih) << 4 + dsl) << 4 + bxl + sil;

    mul [reg_ds + 1], 0x10, [rb + loc_addr]
    add [reg_bx + 1], [rb + loc_addr], [rb + loc_addr]
    add [reg_si + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ds + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_bx + 0], [rb + loc_addr], [rb + loc_addr]
    add [reg_si + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bx_di:
    mul [reg_ds + 1], 0x10, [rb + loc_addr]
    add [reg_bx + 1], [rb + loc_addr], [rb + loc_addr]
    add [reg_di + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ds + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_bx + 0], [rb + loc_addr], [rb + loc_addr]
    add [reg_di + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bp_si:
    mul [reg_ss + 1], 0x10, [rb + loc_addr]
    add [reg_bp + 1], [rb + loc_addr], [rb + loc_addr]
    add [reg_si + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ss + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_bp + 0], [rb + loc_addr], [rb + loc_addr]
    add [reg_si + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bp_di:
    mul [reg_ss + 1], 0x10, [rb + loc_addr]
    add [reg_bp + 1], [rb + loc_addr], [rb + loc_addr]
    add [reg_di + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ss + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_bp + 0], [rb + loc_addr], [rb + loc_addr]
    add [reg_di + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_si:
    mul [reg_ds + 1], 0x10, [rb + loc_addr]
    add [reg_si + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ds + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_si + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_di:
    mul [reg_ds + 1], 0x10, [rb + loc_addr]
    add [reg_di + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ds + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_di + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bp:
    mul [reg_ss + 1], 0x10, [rb + loc_addr]
    add [reg_bp + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ss + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_bp + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_bx:
    mul [reg_ds + 1], 0x10, [rb + loc_addr]
    add [reg_bx + 1], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_ds + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]
    add [reg_bx + 0], [rb + loc_addr], [rb + loc_addr]

    jz  0, decode_mod_rm_mem_calc

decode_mod_rm_memory_direct:
    mul [reg_ds + 1], 0x100, [rb + loc_addr]
    add [reg_ds + 0], [rb + loc_addr], [rb + loc_addr]
    mul [rb + loc_addr], 0x10, [rb + loc_addr]

decode_mod_rm_mem_calc:
    # Return an 8086 physical memory address
    add 1, 0, [rb + loc_type]

    # Add displacement and wrap around to 20 bits
    add [rb + loc_addr], [rb + disp], [rb - 1]
    add 0x100000, 0, [rb - 2]
    arb -2
    call modulo
    add [rb - 4], 0, [rb + loc_addr]

    jz  0, decode_mod_rm_end

decode_mod_rm_reg:
    # Register mode, use the same algorithm that is used to decode REG

    add [rb + rm], 0, [rb - 1]
    add [rb + w], 0, [rb - 2]
    arb -2
    call decode_reg

    add [rb - 4], 0, [rb + loc_type]
    add [rb - 5], 0, [rb + loc_addr]

decode_mod_rm_end:
    arb 4
    ret 3
.ENDFRAME

##########
decode_reg:
.FRAME reg, w; loc_type, loc_addr, tmp                      # return loc_type, loc_addr
    arb -3

    # Expect reg to be 0-7, w to be 0-1

    # Return the intcode address of an 8086 register
    add 0, 0, [rb + loc_type]

    # Map the REG value to an intocode address of the corresponding 8086 register
    mul [rb + w], 8, [rb + tmp]
    add [rb + tmp], [rb + reg], [rb + tmp]
    add decode_reg_table, [rb + tmp], [ip + 1]
    add [0], 0, [rb + loc_addr]

    arb 3
    ret 2

decode_reg_table:
    # Map each w+reg value to the intcode address of corresponding register
    db  reg_al
    db  reg_cl
    db  reg_dl
    db  reg_bl
    db  reg_ah
    db  reg_ch
    db  reg_dh
    db  reg_bh

    db  reg_ax
    db  reg_cx
    db  reg_dx
    db  reg_bx
    db  reg_sp
    db  reg_bp
    db  reg_si
    db  reg_di
.ENDFRAME

##########
decode_sr:
.FRAME reg; loc_type, loc_addr, tmp                      # return loc_type, loc_addr
    arb -3

    # Expect reg to be 0-7, w to be 0-1

    # Only reg 0-3 are valid instructions
    lt  [rb + reg], 4, [rb + tmp]
    jz  [rb + tmp], decode_sr_invalid_instruction

    # Return the intcode address of an 8086 register
    add 0, 0, [rb + loc_type]

    # Map the REG value to an intocode address of the corresponding 8086 segment register
    add decode_sr_table, [rb + reg], [ip + 1]
    add [0], 0, [rb + loc_addr]

    arb 3
    ret 1

decode_sr_invalid_instruction:
    add decode_sr_invalid_instruction_message, 0, [rb - 1]
    arb -1
    call report_error

decode_sr_invalid_instruction_message:
    db  "invalid segment register", 0

decode_sr_table:
    # Map each reg value to the intcode address of corresponding segment register
    db  reg_es
    db  reg_cs
    db  reg_ss
    db  reg_ds
.ENDFRAME

.EOF
