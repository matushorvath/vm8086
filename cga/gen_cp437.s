# Utility to generate cp437.s

# From util/generator.s
.IMPORT gen_number
.IMPORT gen_number_max
.IMPORT gen_number_count

# From libxib.a
.IMPORT print_str
.IMPORT print_num

.IMPORT __heap_start

##########
    arb stack

    # Split each character into bytes
    add 0, 0, [part_count]
    add 0, 0, [char_index]
    add 0, 0, [position]

char_loop_split:
    add 0, 0, [byte_index]

byte_loop:
    # Read next byte
    add data, [position], [ip + 1]
    add [0], 0, [byte]
    add [position], 1, [position]

    # End of character?
    jz  [byte], byte_loop_done

    # Output this byte
    mul [byte_index], 0x100, [tmp]
    add [tmp], [outptr], [tmp]
    add [tmp], [char_index], [ip + 3]
    add [byte], 0, [0]

    # Next byte
    add [byte_index], 1, [byte_index]
    jz  0, byte_loop

byte_loop_done:
    # Update maximum character length
    lt  [part_count], [byte_index], [tmp]
    jz  [tmp], after_max_length
    add [byte_index], 0, [part_count]

after_max_length:
    # Next char
    add [char_index], 1, [char_index]
    eq  [char_index], 0x100, [tmp]
    jz  [tmp], char_loop_split

    # Generate the output
    add file_header, 0, [rb - 1]
    arb -1
    call print_str

    # Intialize the part loop
    add 16, 0, [gen_number_max]

part_loop:
    # Part header
    add part_header, 0, [rb - 1]
    arb -1
    call print_str

    add [part_index], 0, [rb - 1]
    arb -1
    call print_num
    out ':'

    # Intialize the char loop
    add 0, 0, [gen_number_count]
    add 0, 0, [char_index]

char_loop_gen:
    # Output a byte of this character
    add [outptr], [char_index], [ip + 1]
    add [0], 0, [rb - 1]
    add 16, 0, [rb - 2]
    add 2, 0, [rb - 3]
    add number_prefix, 0, [rb - 4]
    arb -4
    call gen_number

    # Next character
    add [char_index], 1, [char_index]
    eq  [char_index], 0x100, [tmp]
    jz  [tmp], char_loop_gen

    # Next part
    add [outptr], 0x100, [outptr]

    add [part_index], 1, [part_index]
    eq  [part_index], [part_count], [tmp]
    jz  [tmp], part_loop

    # Finish the file
    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
part_count:
    db  0
part_index:
    db  0
char_index:
    db  0
byte_index:
    db  0
position:
    db  0
byte:
    db  0
tmp:
    db  0

file_header:
    db  ".EXPORT cp437_0", 10, ".EXPORT cp437_1", 10, ".EXPORT cp437_2"
    db  10, 10, "# Generated using gen_cp437.s", 0

part_header:
    db  10, 10, "cp437_", 0

number_prefix:
    db  "0x", 0

file_footer:
    db  10, 10, ".EOF", 10, 0

# Character data was generated using iconv and manually adjusted
# printf "$(printf \\%03o $(seq 32 255))" | iconv -f CP437 -t UTF8
data:
    db  " ", 0, "☺", 0, "☻", 0, "♥", 0, "♦", 0, "♣", 0, "♠", 0, "•", 0, "◘", 0, "○", 0, "◙", 0, "♂", 0, "♀", 0, "♪", 0, "♫", 0, "☼", 0
    db  "►", 0, "◄", 0, "↕", 0, "‼", 0, "¶", 0, "§", 0, "▬", 0, "↨", 0, "↑", 0, "↓", 0, "→", 0, "←", 0, "∟", 0, "↔", 0, "▲", 0, "▼", 0
    db  " ", 0, "!", 0, "\"", 0, "#", 0, "$", 0, "%", 0, "&", 0, "'", 0, "(", 0, ")", 0, "*", 0, "+", 0, ",", 0, "-", 0, ".", 0, "/", 0
    db  "0", 0, "1", 0, "2", 0, "3", 0, "4", 0, "5", 0, "6", 0, "7", 0, "8", 0, "9", 0, ":", 0, ";", 0, "<", 0, "=", 0, ">", 0, "?", 0
    db  "@", 0, "A", 0, "B", 0, "C", 0, "D", 0, "E", 0, "F", 0, "G", 0, "H", 0, "I", 0, "J", 0, "K", 0, "L", 0, "M", 0, "N", 0, "O", 0
    db  "P", 0, "Q", 0, "R", 0, "S", 0, "T", 0, "U", 0, "V", 0, "W", 0, "X", 0, "Y", 0, "Z", 0, "[", 0, "\\", 0, "]", 0, "^", 0, "_", 0
    db  "`", 0, "a", 0, "b", 0, "c", 0, "d", 0, "e", 0, "f", 0, "g", 0, "h", 0, "i", 0, "j", 0, "k", 0, "l", 0, "m", 0, "n", 0, "o", 0
    db  "p", 0, "q", 0, "r", 0, "s", 0, "t", 0, "u", 0, "v", 0, "w", 0, "x", 0, "y", 0, "z", 0, "{", 0, "|", 0, "}", 0, "~", 0, "⌂", 0
    db  "Ç", 0, "ü", 0, "é", 0, "â", 0, "ä", 0, "à", 0, "å", 0, "ç", 0, "ê", 0, "ë", 0, "è", 0, "ï", 0, "î", 0, "ì", 0, "Ä", 0, "Å", 0
    db  "É", 0, "æ", 0, "Æ", 0, "ô", 0, "ö", 0, "ò", 0, "û", 0, "ù", 0, "ÿ", 0, "Ö", 0, "Ü", 0, "¢", 0, "£", 0, "¥", 0, "₧", 0, "ƒ", 0
    db  "á", 0, "í", 0, "ó", 0, "ú", 0, "ñ", 0, "Ñ", 0, "ª", 0, "º", 0, "¿", 0, "⌐", 0, "¬", 0, "½", 0, "¼", 0, "¡", 0, "«", 0, "»", 0
    db  "░", 0, "▒", 0, "▓", 0, "│", 0, "┤", 0, "╡", 0, "╢", 0, "╖", 0, "╕", 0, "╣", 0, "║", 0, "╗", 0, "╝", 0, "╜", 0, "╛", 0, "┐", 0
    db  "└", 0, "┴", 0, "┬", 0, "├", 0, "─", 0, "┼", 0, "╞", 0, "╟", 0, "╚", 0, "╔", 0, "╩", 0, "╦", 0, "╠", 0, "═", 0, "╬", 0, "╧", 0
    db  "╨", 0, "╤", 0, "╥", 0, "╙", 0, "╘", 0, "╒", 0, "╓", 0, "╫", 0, "╪", 0, "┘", 0, "┌", 0, "█", 0, "▄", 0, "▌", 0, "▐", 0, "▀", 0
    db  "α", 0, "ß", 0, "Γ", 0, "π", 0, "Σ", 0, "σ", 0, "µ", 0, "τ", 0, "Φ", 0, "Θ", 0, "Ω", 0, "δ", 0, "∞", 0, "φ", 0, "ε", 0, "∩", 0
    db  "≡", 0, "±", 0, "≥", 0, "≤", 0, "⌠", 0, "⌡", 0, "÷", 0, "≈", 0, "°", 0, "∙", 0, "·", 0, "√", 0, "ⁿ", 0, "²", 0, "■", 0, " ", 0

    ds  100, 0
stack:

outptr:
    db  __heap_start

.EOF
