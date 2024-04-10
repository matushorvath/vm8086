.EXPORT execute_rol_b
.EXPORT execute_rol_w
.EXPORT execute_ror_b
.EXPORT execute_ror_w
.EXPORT execute_rcl_b
.EXPORT execute_rcl_w
.EXPORT execute_rcr_b
.EXPORT execute_rcr_w
.EXPORT execute_shl_b
.EXPORT execute_shl_w
.EXPORT execute_shr_b
.EXPORT execute_shr_w
.EXPORT execute_sar_b
.EXPORT execute_sar_w

# From location.s
.IMPORT read_location_b
.IMPORT write_location_b
.IMPORT read_location_w
.IMPORT write_location_w

# From obj/bits.s
.IMPORT bits

# From obj/parity.s
.IMPORT parity

# From state.s
.IMPORT flag_carry
.IMPORT flag_parity
.IMPORT flag_auxiliary_carry
.IMPORT flag_zero
.IMPORT flag_sign
.IMPORT flag_overflow

# TODO remove
execute_rol_b:
execute_rol_w:
execute_ror_b:
execute_ror_w:
execute_rcl_b:
execute_rcl_w:
execute_rcr_b:
execute_rcr_w:
execute_shl_b:
execute_shl_w:
execute_shr_b:
execute_shr_w:
execute_sar_b:
execute_sar_w:

##########
execute_shl_b:
.FRAME loc_type_val, loc_addr_val, loc_type_cnt, loc_addr_cnt; val, cnt, tmp
    arb -X

    add 0, 0, [flag_auxiliary_carry]

    # Read the number of bits
    add [rb + loc_type_cnt], 0, [rb - 1]
    add [rb + loc_addr_cnt], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + cnt]

    # If we are shifting by 9 or more bits, just zero the value
    # If we are shifting by 0 or 8 bits, we still want to calculate the flags
    lt  [rb + cnt], 9, [rb + tmp]
    jz  [rb + tmp], execute_shl_b_many

    # Read the value to shift
    add [rb + loc_type_src], 0, [rb - 1]
    add [rb + loc_addr_src], 0, [rb - 2]
    arb -2
    call read_location_b
    add [rb - 4], 0, [rb + a]

    # Carry is the last bit shifted out
    mul [rb + val], 8, [rb + tmp]
    add bits, [rb + tmp], [rb + tmp]
    add [rb + a_bits], [rb + bit], [ip + 5]
TODO

    # Shift by less than 8 bits by multiplying by a power of two
    add power_of_two, [rb + cnt], [ip + 1]
    mul [0], [rb + val], [rb + val]

    # Update flags
    lt  0x7f, [rb + res], [flag_sign]
    eq  [rb + res], 0, [flag_zero]

    add parity, [rb + res], [ip + 1]
    add [0], 0, [flag_parity]

    # TODO CF is last bit shifted out
    # TODO OF undefined for multibit shift, for one bit it's 1 when hi order bit changed

    jz  0, execute_shl_b_store

execute_shl_b_many:
    # Shift by 9 or more bits
    add 0, 0, [rb + val]
    add 1, 0, [flag_parity]
    add 0, 0, [flag_sign]
    add 1, 0, [flag_zero]
    add 0, 0, [flag_carry]

execute_shl_b_store:
    # Write the shifted value
    add [rb + loc_type_val], 0, [rb - 1]
    add [rb + loc_addr_val], 0, [rb - 2]
    add [rb + val], 0, [rb - 3]
    arb -3
    call write_location_b

    arb X
    ret 4
.ENDFRAME

power_of_two:
    db  0x01, 0x02, 0x04, 0x08
    db  0x10, 0x20, 0x40, 0x80

.EOF
