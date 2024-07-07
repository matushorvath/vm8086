.EXPORT reset_screen
.EXPORT enable_disable_screen

.EXPORT screen_needs_redraw
.EXPORT screen_width_chars
.EXPORT screen_height_chars

# From graphics_mode.s
.IMPORT initialize_graphics_mode
.IMPORT redraw_screen_graphics

# From text_mode.s
.IMPORT initialize_text_mode
.IMPORT redraw_screen_text

# From registers.s
.IMPORT mode_graphics
.IMPORT mode_enable_output

# From status_bar.s
.IMPORT redraw_status_bar

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

    # Screen width is 80 chars (even in 40 char mode), height is 25 chars
    add 80, 0, [screen_width_chars]
    add 25, 0, [screen_height_chars]

    # Prepare for drawing the text mode
    call initialize_text_mode

    # Redraw the screen
    call redraw_screen_text

reset_screen_redraw_status_bar:
    # Redraw the status line
    call redraw_status_bar

    ret 0
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

# Screen width and height, for placing the status bar
screen_width_chars:
    db  80
screen_height_chars:
    db  25

.EOF
