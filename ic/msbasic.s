.EXPORT binary_load_address

##########
# configuration for the VM6502 that is specific to the MS Basic image

# TODO
#
# Ideally we want bin2obj to export symbols like __bin2obj_vm6502bin_data,  which would allow linking
# multiple bin2obj outputs. However, then we have no easy way to refer to those binaries from generic code.
#
# What would help is if xz supports renaming symbols, then we could define this here:
# .SYMBOL binary_data __bin2obj_vm6502bin_data
# .SYMBOL binary_length __bin2obj_vm6502bin_length
# This allows us to use binary_data and binary_length to refer to the binary in a generic way.
#
# For now, bin2obj exports binary_data and binary_length directly, since one binary is anyway all we need.

# load address for the MSBASIC binary, needs to match the BASROM memory region in $(MSBASICDIR)/vm6502.cfg.
#
# TODO this should ideally just be a symbol, but xz as does not support .EXPORT of a .SYMBOL
# (because .SYMBOL is never relocated and .EXPORT is assumed to be an address and relocated)
# .SYMBOL binary_load_address 49152        # 0xc000

binary_load_address:
    db 49152        # 0xc000

.EOF
