.EXPORT binary

##########
# start of the binary to execute
#
# This needs to be the last object file linked into the VM, except for the 8086 binary to be executed.
# It exports the "binary" symbol that will either be followed by the linked-in binary, or by the
# concatenated binary in case no binary is linked in.
#
# We want the VM to be usable with a compiled-in binary, as well as just concatenating a binary
# immediately after the vm.input image. Because of this, we can't expect the binary to export any
# symbols (because those would not be present in an image without binary, so it wouldn't link).
#
# The end of the vm.input image is marked by the linker using the __heap_start symbol, which is
# also used by heap.s in libxib. The VM without a binary must not use the heap unless it takes
# care the overlap between the heap and the appended binary image.

binary:

# After this we expect:
#
# binary_start_address_ip:
#    db  0x0000       # starting ip value is 0x0000 (default for real hardware)
#
# binary_start_address_cs:
#    db  0xffff       # starting cs value is 0xffff (default for real hardware)
#
# binary_load_address:
#    db  0xc000       # load address of the binary image in 8086 memory
#
# tracing:
#    db  1            # 0 - disable tracing, -1 - trace always, >0 - start tracing after passing that address
#
# vm_callback:
#    db  0xabcde      # optional callback function to call before each instruction
#
# binary_length:
#    db  0x4000       # size of the binary image
#
# binary_data:
#    ds  0x4000, 0    # binary image data

.EOF
