# Utility to generate cp437.s

# From unicode.s
.IMPORT generate_unicode

# From libxib.a
.IMPORT print_str

##########
    arb stack

    # Generate the output
    add file_header, 0, [rb - 1]
    arb -1
    call print_str

    add identifier, 0, [rb - 1]
    add data, 0, [rb - 2]
    add 0x100, 0, [rb - 3]
    arb -3
    call generate_unicode

    add file_footer, 0, [rb - 1]
    arb -1
    call print_str

    hlt

##########
file_header:
    db  ".EXPORT cp437_0", 10, ".EXPORT cp437_1", 10, ".EXPORT cp437_2"
    db  10, 10, "# Generated using gen_cp437.s", 0

identifier:
    db  "cp437", 0

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

.EOF
