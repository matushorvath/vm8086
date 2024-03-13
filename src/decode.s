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

##########
decode_mod_rm:
.FRAME w; addr, mod, reg, rm, disp, tmp                     # return addr
    arb -6

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
    eq  [rb + mod], 0b00, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_mod00
    eq  [rb + mod], 0b01, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_disp8
    eq  [rb + mod], 0b10, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_disp16
    eq  [rb + mod], 0b11, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg

    add decode_mod_rm_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

decode_mod_rm_mem_mod00:
    # Memory mode, no displacement; except when R/M is 0b110, then 16-bit displacement follows
    eq  [rb + rm], 0x110, [rb + tmp]
    jz  [rb + tmp], decode_mod_rm_mem_no_disp

    # Handle the special case with a fake R/M value of 0xffff
    add 0xffff, 0, [rb + rm]
    jz  0, decode_mod_rm_mem_disp16

decode_mod_rm_mem_no_disp:
    # Memory mode with no displacement
    add 0, 0, [rb + disp]

    jz  0, decode_mod_rm_memory_mode

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
    jnz [rb + tmp], decode_mod_rm_memory_mode

    add [rb + disp], 0xff00, [rb + disp]

    jz  0, decode_mod_rm_memory_mode

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

decode_mod_rm_memory_mode:              # TODO consider using a table, not eq/jnz
    # Calculate physical address based on R/M
    eq  [rb + rm], 0x000, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_bx_si
    eq  [rb + rm], 0x001, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_bx_di
    eq  [rb + rm], 0x010, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_bp_si
    eq  [rb + rm], 0x011, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_bp_di
    eq  [rb + rm], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_si
    eq  [rb + rm], 0x101, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_di
    eq  [rb + rm], 0x110, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_bp
    eq  [rb + rm], 0x111, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_bx
    eq  [rb + rm], 0xffff, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_memory_direct

    add decode_mod_rm_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

decode_mod_rm_memory_bx_si:
    add [reg_bx + 1], [reg_si + 1], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_ds], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_bx + 0], [rb + addr]
    add [rb + addr], [reg_si + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_bx_di:
    add [reg_bx + 1], [reg_di + 1], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_ds], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_bx + 0], [rb + addr]
    add [rb + addr], [reg_di + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_bp_si:
    add [reg_bp + 1], [reg_si + 1], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_ss], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_bp + 0], [rb + addr]
    add [rb + addr], [reg_si + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_bp_di:
    add [reg_bp + 1], [reg_di + 1], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_ss], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_bp + 0], [rb + addr]
    add [rb + addr], [reg_di + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_si:
    mul [reg_si + 1], 0xf, [rb + addr]
    add [rb + addr], [reg_ds], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_si + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_di:
    mul [reg_di + 1], 0xf, [rb + addr]
    add [rb + addr], [reg_ds], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_di + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_bp:
    mul [reg_bp + 1], 0xf, [rb + addr]
    add [rb + addr], [reg_ss], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_bp + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_bx:
    mul [reg_bx + 1], 0xf, [rb + addr]
    add [rb + addr], [reg_ds], [rb + addr]
    mul [rb + addr], 0xf, [rb + addr]
    add [rb + addr], [reg_bx + 0], [rb + addr]

    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_memory_direct:
    mul [reg_ds], 0xf, [rb + addr]
    jz  0, decode_mod_rm_memory_calc

decode_mod_rm_reg:
    # Register mode, no displacement

    # Determine if it is a 8-bit or a 16-bit register
    jz  [rb + w], decode_mod_rm_reg8
    eq  [rb + w], 1, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg16

    add decode_mod_rm_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

decode_mod_rm_reg8:                     # TODO use a table, not eq/jnz
    eq  [rb + rm], 0x000, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_al
    eq  [rb + rm], 0x001, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_cl
    eq  [rb + rm], 0x010, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_dl
    eq  [rb + rm], 0x011, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_bl
    eq  [rb + rm], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_ah
    eq  [rb + rm], 0x101, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_ch
    eq  [rb + rm], 0x110, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_dh
    eq  [rb + rm], 0x111, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_bh

    add decode_mod_rm_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

decode_mod_rm_reg16:                    # TODO use a table, not eq/jnz
    eq  [rb + rm], 0x000, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_ax
    eq  [rb + rm], 0x001, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_cx
    eq  [rb + rm], 0x010, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_dx
    eq  [rb + rm], 0x011, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_bx
    eq  [rb + rm], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_sp
    eq  [rb + rm], 0x101, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_bp
    eq  [rb + rm], 0x110, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_si
    eq  [rb + rm], 0x111, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_reg_di

    add decode_mod_rm_invalid_message, 0, [rb - 1]
    arb -1
    call report_error

decode_mod_rm_reg_al:
    add reg_al, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_cl:
    add reg_cl, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_dl:
    add reg_dl, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bl:
    add reg_bl, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_ah:
    add reg_ah, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_ch:
    add reg_ch, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_dh:
    add reg_dh, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bh:
    add reg_bh, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_ax:
    add reg_ax, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_cx:
    add reg_cx, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_dx:
    add reg_dx, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bx:
    add reg_bx, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_sp:
    add reg_sp, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_bp:
    add reg_bp, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_si:
    add reg_si, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_reg_di:
    add reg_di, 0, [rb + addr]
    jz  0, decode_mod_rm_end

decode_mod_rm_memory_calc:
    # Add displacement and wrap around to 20 bits
    # Then add the 8086 memory start address to make an intcode address

    add [rb + addr], [rb + disp], [rb - 1]
    add 0x100000, 0, [rb - 2]
    arb -2
    call mod
    add [rb - 4], [memory], [rb + addr]         # TODO don't do this, return a 8086 memory address somehow, to handle MM IO and ROMs

decode_mod_rm_end:
    arb 6
    ret 1

decode_mod_rm_invalid_message:
    db  "invalid instruction while decoding MOD REG R/M", 0

.ENDFRAME

.EOF
