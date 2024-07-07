.EXPORT reset_screen
.EXPORT enable_disable_screen

.EXPORT screen_needs_redraw
.EXPORT screen_page_size
.EXPORT screen_text_negative_row_size
.EXPORT screen_text_row_shr_table
.EXPORT screen_width_chars
.EXPORT screen_height_chars

# From graphics_mode_lo.s
.IMPORT initialize_graphics_mode
.IMPORT redraw_screen_graphics

# From text_palette.s
.IMPORT reinitialize_text_palette

# From text_mode.s
.IMPORT redraw_screen_text

# From registers.s
.IMPORT mode_high_res_text
.IMPORT mode_graphics
.IMPORT mode_enable_output

# From status_bar.s
.IMPORT redraw_status_bar

# From util/shr.s
.IMPORT shr_0
.IMPORT shr_1

##########
reset_screen:
.FRAME
    # Clear the terminal
    # TODO no need to clear if we're redrawing the same data with different palette
    out 0x1b
    out '['
    out '2'
    out 'J'

    # Graphics mode?
    jz  [mode_graphics], reset_screen_text

    # Screen width is 320/2 [640/4] = 160 characters, height is 200/4 = 50 characters
    add 160, 0, [screen_width_chars]
    add 50, 0, [screen_height_chars]

    # Prepare for drawing the graphics mode
    call initialize_graphics_mode

    # Redraw the screen
    call redraw_screen_graphics

    jz  0, reset_screen_redraw_status_bar

reset_screen_text:
    # Text mode

    # Negative value of screen row size; -160 for 80x25, -80 for 40x25
    mul [mode_high_res_text], -80, [screen_text_negative_row_size]
    add [screen_text_negative_row_size], -80, [screen_text_negative_row_size]

    # Right shift table used to divide address into rows, shr_1 for 80x25, shr_0 for 40x25
    add reset_screen_row_shr_tables, [mode_high_res_text], [ip + 1]
    add [0], 0, [screen_text_row_shr_table]

    # Screen width is 80 chars (even in 40 char mode), height is 25 chars
    add 80, 0, [screen_width_chars]
    add 25, 0, [screen_height_chars]

    # Page size is 25 rows * 80/160 bytes per row = 2000/4000 bytes depending on column count
    add [mode_high_res_text], 1, [screen_page_size]
    mul [screen_page_size], 2000, [screen_page_size]

    # Initialize the palette for text mode
    call reinitialize_text_palette

    # Redraw the screen
    call redraw_screen_text

reset_screen_redraw_status_bar:
    # Redraw the status line
    call redraw_status_bar

    ret 0

reset_screen_row_shr_tables:
    db  shr_0
    db  shr_1
.ENDFRAME

##########
enable_disable_screen:
.FRAME
    # Is the screen being enabled or disabled?
    jz  [mode_enable_output], enable_screen_done

    # Redraw the screen if it no longer matches CGA memory
    jz [screen_needs_redraw], enable_screen_done

    # Graphics mode?
    jz  [mode_graphics], enable_screen_text

    # Redraw the screen for 320x200
    call redraw_screen_graphics

    jz  0, enable_screen_done

enable_screen_text:
    # Redraw the screen
    call redraw_screen_text

enable_screen_done:
    ret 0
.ENDFRAME

##########
# Precalculated values used in address to row/column conversion
# The defaults are set up for 80x25 text mode, which is the mode used at boot

# Flag to mark that the screen will need a redraw once output is enabled again
screen_needs_redraw:
    db  0

# One screen page size
# TODO move to text_mode
screen_page_size:
    db  4000                            # 25 rows * 160 bytes per row

# Negative value of screen row size; -160 for 80x25, -80 for 40x25
# TODO move to text_mode
screen_text_negative_row_size:
    db  -160
# Right shift table used to divide address into rows, shr_1 for 80x25, shr_0 for 40x25
# TODO move to text_mode
screen_text_row_shr_table:
    db  shr_1

# Screen width and height, for placing the status bar
screen_width_chars:
    db  80
screen_height_chars:
    db  25

.EOF
