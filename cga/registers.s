.EXPORT mc6845_address_read
.EXPORT mc6845_address_write
.EXPORT mc6845_data_read
.EXPORT mc6845_data_write
.EXPORT mode_control_write
.EXPORT color_control_write
.EXPORT status_read

##########
mc6845_address_read:
.FRAME port; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

##########
mc6845_address_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
mc6845_data_read:
.FRAME port; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

##########
mc6845_data_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
mode_control_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
color_control_write:
.FRAME addr, value;
    ret 2
.ENDFRAME

##########
status_read:
.FRAME port; value                      # returns value
    arb -1

    arb 1
    ret 1
.ENDFRAME

.EOF
