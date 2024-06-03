.EXPORT terminal_normal_buffer
.EXPORT terminal_alternate_buffer
.EXPORT terminal_clear_display

.EXPORT terminal_save_cursor
.EXPORT terminal_restore_cursor
.EXPORT terminal_set_cursor

.EXPORT terminal_show_cursor
.EXPORT terminal_hide_cursor
.EXPORT 
.EXPORT 
.EXPORT 

# From obj/printb.s
.IMPORT printb


##########
terminal_normal_buffer:
.FRAME
    out 0x1b
    out '['
    out '?'
    out '4'
    out 'l'
    ret 0
.ENDFRAME

##########
terminal_alternate_buffer:
.FRAME
    out 0x1b
    out '['
    out '?'
    out '4'
    out 'h'
    ret 0
.ENDFRAME

##########
terminal_clear_display:
.FRAME
    out 0x1b
    out '['
    out '2'
    out 'J'
    ret 0
.ENDFRAME

##########
terminal_save_cursor:
.FRAME
    out 0x1b
    out '7'
    ret 0
.ENDFRAME

##########
terminal_restore_cursor:
.FRAME
    out 0x1b
    out '8'
    ret 0
.ENDFRAME

##########
terminal_set_cursor:
.FRAME row, col;
    out 0x1b
    out '['

    add [rb + row], 0, [rb - 1]
    arb -1
    call printb

    out ';'

    add [rb + col], 0, [rb - 1]
    arb -1
    call printb

    out 'H'

    ret 2
.ENDFRAME

##########
terminal_show_cursor:
.FRAME
    out 0x1b
    out '['
    out '?'
    out '2'
    out '5'
    out 'h'
    ret 0
.ENDFRAME

##########
terminal_hide_cursor:
.FRAME
    out 0x1b
    out '['
    out '?'
    out '2'
    out '5'
    out 'l'
    ret 0
.ENDFRAME

##########
terminal_set_color:
.FRAME fg_color, fg_bright, bg_color, bg_bright;
    out 0x1b
    out '['
    out '?'
    out '2'
    out '5'
    out 'l'

    ret 2
.ENDFRAME

##########
terminal_set_background:
.FRAME
    out 0x1b
    out '7'
    ret 0
.ENDFRAME

##########
terminal_save_cursor:
.FRAME
    out 0x1b
    out '7'
    ret 0
.ENDFRAME

##########
color:
    db  "

\033[31;42m

const setForeground = (r, g, b) => process.stdout.write(`\x1b[38;2;${r};${g};${b}m`);
const setBackground = (r, g, b) => process.stdout.write(`\x1b[48;2;${r};${g};${b}m`);
const resetColor = () => process.stdout.write('\x1b[0m');