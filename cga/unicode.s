.EXPORT generate_unicode

# From util/generator.s
.IMPORT gen_number
.IMPORT gen_number_max
.IMPORT gen_number_count

# From libxib.a
.IMPORT print_str
.IMPORT print_num

.IMPORT __heap_start

##########
generate_unicode:
.FRAME identifier, chars, char_count;
    add [rb + chars], 0, [rb - 1]
    add [rb + char_count], 0, [rb - 2]
    arb -2
    call build_tables

    add [rb + identifier], 0, [rb - 1]
    add [rb + char_count], 0, [rb - 2]
    arb -2
    call output_tables

    ret 3
.ENDFRAME

##########
build_tables:
.FRAME chars, char_count; char_index, byte_index, position, byte, tmp
    arb -5

    # Split each character into bytes
    add 0, 0, [table_count]
    add 0, 0, [rb + char_index]
    add 0, 0, [rb + position]

.char_loop:
    add 0, 0, [rb + byte_index]

.byte_loop:
    # Read next byte
    add [rb + chars], [rb + position], [ip + 1]
    add [0], 0, [rb + byte]
    add [rb + position], 1, [rb + position]

    # End of character?
    jz  [rb + byte], .byte_loop_done

    # Output this byte
    mul [rb + byte_index], [rb + char_count], [rb + tmp]
    add [rb + tmp], [tables], [rb + tmp]
    add [rb + tmp], [rb + char_index], [ip + 3]
    add [rb + byte], 0, [0]

    # Next byte
    add [rb + byte_index], 1, [rb + byte_index]
    jz  0, .byte_loop

.byte_loop_done:
    # Update maximum character length
    lt  [table_count], [rb + byte_index], [rb + tmp]
    jz  [rb + tmp], .after_table_count
    add [rb + byte_index], 0, [table_count]

.after_table_count:
    # Next char
    add [rb + char_index], 1, [rb + char_index]
    eq  [rb + char_index], [rb + char_count], [rb + tmp]
    jz  [rb + tmp], .char_loop

    arb 5
    ret 2
.ENDFRAME

##########
output_tables:
.FRAME identifier, char_count; part_index, char_index, tmp
    arb -3

    # Intialize the part loop
    add 16, 0, [gen_number_max]
    add 0, 0, [rb + part_index]

.part_loop:
    # Part header
    out 10
    out 10

    add [rb + identifier], 0, [rb - 1]
    arb -1
    call print_str
    out '_'

    add [rb + part_index], 0, [rb - 1]
    arb -1
    call print_num
    out ':'

    # Intialize the char loop
    add 0, 0, [gen_number_count]
    add 0, 0, [rb + char_index]

.char_loop:
    # Output a byte of this character
    add [tables], [rb + char_index], [ip + 1]
    add [0], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add .number_prefix, 0, [rb - 4]
    arb -4
    call gen_number

    # Next character
    add [rb + char_index], 1, [rb + char_index]
    eq  [rb + char_index], [rb + char_count], [rb + tmp]
    jz  [rb + tmp], .char_loop

    # Next part
    add [tables], [rb + char_count], [tables]

    add [rb + part_index], 1, [rb + part_index]
    eq  [rb + part_index], [table_count], [rb + tmp]
    jz  [rb + tmp], .part_loop

    arb 3
    ret 2

.number_prefix:
    db  "0x", 0
.ENDFRAME

##########
table_count:
    db  0
tables:
    db  __heap_start

.EOF
