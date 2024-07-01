.EXPORT reset_screen
.EXPORT screen_page_size
.EXPORT screen_row_size_160

# From palette.s
.IMPORT reinitialize_palette

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
    # Set screen parameters based on register values
    jz  [mode_graphics], reset_screen_text

    # Graphics mode; screen row size is always 80 bytes
    add 0, 0, [screen_row_size_160]

    # Page size is 200 rows * 80 bytes per row = 16000 bytes
    add 16000, 0, [screen_page_size]

    jz  0, reset_screen_redraw_memory

reset_screen_text:
    # Text mode; screen row is 160 bytes in 80x25 mode, 80 bytes otherwise
    add [mode_high_res_text], 0, [screen_row_size_160]

    # Page size is 25 rows * 80/160 bytes per row = 2000/4000 bytes depending on column count
    add [mode_high_res_text], 1, [screen_page_size]
    mul [screen_page_size], 2000, [screen_page_size]

    # Palette for background
    call reinitialize_palette

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
# Precalculated values used in address to row/column conversion
# The defaults are set up for 80x25 text mode, which is the mode used at boot

# One screen page size
screen_page_size:
    db  4000                            # 25 rows * 160 bytes per row

# Every screen row is 160 bytes in 80x25 text mode, 80 bytes in all other modes
screen_row_size_160:
    db  1

.EOF
