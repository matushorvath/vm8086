.EXPORT reset_screen
.EXPORT screen_cols

# From registers.s
.IMPORT mode_high_res_text
.IMPORT mode_graphics
.IMPORT mode_enable_output
.IMPORT mode_high_res_graphics

# From status.s
.IMPORT redraw_vm_status

##########
reset_screen:
.FRAME
    # Clear the terminal
    out 0x1b
    out '['
    out '2'
    out 'J'

    # Set screen parameters based on register values
    jz  [mode_graphics], reset_screen_text

    # Graphics mode; 320 or 640?
    add [mode_high_res_graphics], 1, [screen_cols]
    mul [screen_cols], 320, [screen_cols]

    jz  0, reset_screen_redraw_memory

reset_screen_text:
    # Text mode; 80 or 40?
    add [mode_high_res_text], 1, [screen_cols]
    mul [screen_cols], 40, [screen_cols]

reset_screen_redraw_memory:
    # Don't redraw the memory if output is disabled
    jz  [mode_enable_output], reset_screen_redraw_vm_status

    # TODO redraw the memory in new mode

reset_screen_redraw_vm_status:
    # Redraw the status line
    call redraw_vm_status

    ret 0
.ENDFRAME

##########
# Screen columns: 40 or 80 for text mode, 320 or 640 for graphics mode
screen_cols:
    db  80

.EOF
