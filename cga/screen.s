.EXPORT initialize_screen
.EXPORT redraw_screen
.EXPORT enable_disable_screen

.EXPORT screen_needs_redraw
.EXPORT screen_width_chars
.EXPORT screen_height_chars

# From graphics_mode.s
.IMPORT initialize_graphics_mode
.IMPORT redraw_screen_graphics

# From graphics_palette.s
.IMPORT initialize_graphics_palette

# From registers.s
.IMPORT mode_graphics
.IMPORT mode_enable_output
.IMPORT mode_high_res_graphics

# From status_bar.s
.IMPORT redraw_status_bar

# From text_mode.s
.IMPORT initialize_text_mode
.IMPORT redraw_screen_text

# From text_palette.s
.IMPORT initialize_text_palette

##########
initialize_screen:
.FRAME
    # Completely reinitialize the screen; this is used after a mode change,
    # when desired image does not even resemble what's currently on screen

    # Clear the terminal
    out 0x1b
    out '['
    out '2'
    out 'J'

    # Graphics mode?
    jz  [mode_graphics], initialize_screen_text

    # Screen width is 320/2 [640/4] = 160 characters, height is 200/4 = 50 characters
    add 160, 0, [screen_width_chars]
    add 50, 0, [screen_height_chars]

    # Initialize the palette for graphics mode
    call initialize_graphics_palette

    # Prepare for drawing the graphics mode
    call initialize_graphics_mode

    # Redraw the screen
    call redraw_screen_graphics

    jz  0, initialize_screen_redraw_status_bar

initialize_screen_text:
    # Text mode

    # Screen width is 80 chars (even in 40 char mode), height is 25 chars
    add 80, 0, [screen_width_chars]
    add 25, 0, [screen_height_chars]

    # Initialize the palette for text mode
    call initialize_text_palette

    # Prepare for drawing the text mode
    call initialize_text_mode

    # Redraw the screen
    call redraw_screen_text

initialize_screen_redraw_status_bar:
    # Redraw the status line
    call redraw_status_bar

    ret 0
.ENDFRAME

##########
redraw_screen:
.FRAME
    # Redraw the screen, potentially with a new palette; this is used after a palette change,
    # when desired image roughly matches what's screen, so we don't need to erase it

    # Graphics mode?
    jz  [mode_graphics], reset_screen_text

    # Initialize the palette for graphics mode
    call initialize_graphics_palette

    # Redraw the screen
    call redraw_screen_graphics

    jz  0, reset_screen_done

reset_screen_text:
    # Text mode

    # Initialize the palette for text mode
    call initialize_text_palette

    # Redraw the screen
    call redraw_screen_text

reset_screen_done:
    ret 0
.ENDFRAME

##########
enable_disable_screen:
.FRAME
    # Is the screen being enabled or disabled?
    jz  [mode_enable_output], enable_disable_screen_done

    # Redraw the screen if it no longer matches CGA memory
    jz [screen_needs_redraw], enable_disable_screen_done

    # Graphics mode?
    jz  [mode_graphics], enable_disable_screen_text

    # Redraw the screen for 320x200
    call redraw_screen_graphics

    jz  0, enable_disable_screen_done

enable_disable_screen_text:
    # Redraw the screen
    call redraw_screen_text

enable_disable_screen_done:
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
