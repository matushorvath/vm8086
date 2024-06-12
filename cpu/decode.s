.EXPORT decode_mod_rm
.EXPORT decode_reg
.EXPORT decode_sr

# From util/error.s
.IMPORT report_error

# From memory.s
.IMPORT read_cs_ip_b
.IMPORT read_cs_ip_w

# From prefix.s
.IMPORT ds_segment_prefix
.IMPORT ss_segment_prefix

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

.IMPORT inc_ip_b
.IMPORT inc_ip_w

##########
decode_mod_rm:
.FRAME mod, rm, w; regptr, seg_lo, seg_hi, off_lo, off_hi, disp_lo, disp_hi, tmp    # returns regptr, seg_lo, seg_hi, off_lo, off_hi
    arb -8

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
    add 0, 0, [rb + disp_lo]
    add 0, 0, [rb + disp_hi]

    # Jump to handling of this R/M value
    add decode_mod_rm_mem_table, [rb + rm], [ip + 2]
    jz  0, [0]

decode_mod_rm_mem_disp8:
    # Memory mode with 8-bit displacement

    # Read 8-bit displacement
    call read_cs_ip_b
    add [rb - 2], 0, [rb + disp_lo]
    call inc_ip_b

    # Sign extend the displacement
    lt  0x7f, [rb + disp_lo], [rb + disp_hi]
    mul [rb + disp_hi], 0xff, [rb + disp_hi]

    # Jump to handling of this R/M value
    add decode_mod_rm_mem_table, [rb + rm], [ip + 2]
    jz  0, [0]

decode_mod_rm_mem_disp16:
    # Memory mode with 16-bit displacement

    # Read 16-bit displacement
    call read_cs_ip_w
    add [rb - 2], 0, [rb + disp_lo]
    add [rb - 3], 0, [rb + disp_hi]
    call inc_ip_w

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
    # Segment to return
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ds_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return, carry will be handled later
    add [reg_bx + 0], [reg_si + 0], [rb + off_lo]
    add [reg_bx + 1], [reg_si + 1], [rb + off_hi]

    jz  0, decode_mod_rm_mem_offset_carry

decode_mod_rm_memory_bx_di:
    # Segment to return
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ds_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return, carry will be handled later
    add [reg_bx + 0], [reg_di + 0], [rb + off_lo]
    add [reg_bx + 1], [reg_di + 1], [rb + off_hi]

    jz  0, decode_mod_rm_mem_offset_carry

decode_mod_rm_memory_bp_si:
    # Segment to return
    add [ss_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ss_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return, carry will be handled later
    add [reg_bp + 0], [reg_si + 0], [rb + off_lo]
    add [reg_bp + 1], [reg_si + 1], [rb + off_hi]

    jz  0, decode_mod_rm_mem_offset_carry

decode_mod_rm_memory_bp_di:
    # Segment to return
    add [ss_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ss_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return, carry will be handled later
    add [reg_bp + 0], [reg_di + 0], [rb + off_lo]
    add [reg_bp + 1], [reg_di + 1], [rb + off_hi]

    jz  0, decode_mod_rm_mem_offset_carry

decode_mod_rm_memory_si:
    # Segment to return
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ds_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return
    add [reg_si + 0], 0, [rb + off_lo]
    add [reg_si + 1], 0, [rb + off_hi]

    jz  0, decode_mod_rm_mem_disp

decode_mod_rm_memory_di:
    # Segment to return
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ds_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return
    add [reg_di + 0], 0, [rb + off_lo]
    add [reg_di + 1], 0, [rb + off_hi]

    jz  0, decode_mod_rm_mem_disp

decode_mod_rm_memory_bp:
    # Segment to return
    add [ss_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ss_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return
    add [reg_bp + 0], 0, [rb + off_lo]
    add [reg_bp + 1], 0, [rb + off_hi]

    jz  0, decode_mod_rm_mem_disp

decode_mod_rm_memory_bx:
    # Segment to return
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ds_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return
    add [reg_bx + 0], 0, [rb + off_lo]
    add [reg_bx + 1], 0, [rb + off_hi]

    jz  0, decode_mod_rm_mem_disp

decode_mod_rm_memory_direct:
    # Segment to return
    add [ds_segment_prefix], 0, [ip + 1]
    add [0], 0, [rb + seg_lo]
    add [ds_segment_prefix], 1, [ip + 1]
    add [0], 0, [rb + seg_hi]

    # Offset to return is just the displacement that is added later
    add 0, 0, [rb + off_lo]
    add 0, 0, [rb + off_hi]

    jz  0, decode_mod_rm_mem_disp

decode_mod_rm_mem_offset_carry:
    # Handle carry between off_lo and off_hi

    # Check for carry out of low byte
    lt  [rb + off_lo], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_offset_after_carry_lo

    add [rb + off_lo], -0x100, [rb + off_lo]
    add [rb + off_hi], 1, [rb + off_hi]

decode_mod_rm_mem_offset_after_carry_lo:
    # Check for carry out of high byte
    lt  [rb + off_hi], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_disp

    add [rb + off_hi], -0x100, [rb + off_hi]

decode_mod_rm_mem_disp:
    # Add displacement to offset and once again handle carry
    add [rb + off_lo], [rb + disp_lo], [rb + off_lo]
    add [rb + off_hi], [rb + disp_hi], [rb + off_hi]

    # Check for carry out of low byte
    lt  [rb + off_lo], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_disp_after_carry_lo

    add [rb + off_lo], -0x100, [rb + off_lo]
    add [rb + off_hi], 1, [rb + off_hi]

decode_mod_rm_mem_disp_after_carry_lo:
    # Check for carry out of high byte
    lt  [rb + off_hi], 0x100, [rb + tmp]
    jnz [rb + tmp], decode_mod_rm_mem_disp_after_carry_hi

    add [rb + off_hi], -0x100, [rb + off_hi]

decode_mod_rm_mem_disp_after_carry_hi:
    # Set regptr to 0, since we are returning seg:off
    add 0, 0, [rb + regptr]

    jz  0, decode_mod_rm_end

decode_mod_rm_reg:
    # Register mode, use the same algorithm that is used to decode REG

    add [rb + rm], 0, [rb - 1]
    add [rb + w], 0, [rb - 2]
    arb -2
    call decode_reg
    add [rb - 4], 0, [rb + regptr]

    # We do not zero seg_* and off_* here to save some cycles,
    # but non-zero regptr means seg_* and off_* are not valid

decode_mod_rm_end:
    arb 8
    ret 3
.ENDFRAME

##########
decode_reg:
.FRAME reg, w; regptr, tmp                 # returns reg
    arb -2

    # Return the intcode address of an 8086 register
    # Expect reg to be 0-7, w to be 0-1

    # Map the REG value to an intcode address of the corresponding 8086 register
    mul [rb + w], 8, [rb + tmp]
    add [rb + tmp], [rb + reg], [rb + tmp]
    add decode_reg_table, [rb + tmp], [ip + 1]
    add [0], 0, [rb + regptr]

    arb 2
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
.FRAME reg; regptr, tmp                    # returns reg
    arb -2

    # Return the intcode address of an 8086 register
    # Expect reg to be 0-7, w to be 0-1

    # Map the REG value to an intcode address of the corresponding 8086 segment register
    add decode_sr_table, [rb + reg], [ip + 1]
    add [0], 0, [rb + regptr]

    arb 2
    ret 1

decode_sr_table:
    # Map each reg value to the intcode address of corresponding segment register
    db  reg_es
    db  reg_cs
    db  reg_ss
    db  reg_ds

    # Only reg 0-3 are documented as valid values, but the physical processor ignores
    # the top bit of reg and decodes all values as valid segment registers
    db  reg_es
    db  reg_cs
    db  reg_ss
    db  reg_ds
.ENDFRAME

.EOF
