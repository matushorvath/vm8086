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

# Header of the binary to execute. In this case there is no built-in binary,
# so we just define the symbols to make the VM compile

.EXPORT binary_start_address_cs
.EXPORT binary_start_address_ip
.EXPORT binary_load_address
.EXPORT binary_enable_tracing
.EXPORT binary_vm_callback
.EXPORT binary_length
.EXPORT binary_data

# Initial cs value split into two 8-bit numbers (default for real hardware is 0xff, 0xff)
+0 = binary_start_address_cs:

# Initial ip value split into two 8-bit numbers (default for real hardware is 0x00, 0x00)
+2 = binary_start_address_ip:

# Load address of the binary image in 8086 memory
+4 = binary_load_address:

# Tracing (0 - disable tracing, -1 - trace always, >0 - tracing past given address)
+5 = binary_enable_tracing:

# Optional callback function to call before each instruction, zero if not used
+6 = binary_vm_callback:

# Size of the binary image
+7 = binary_length:

# Binary image data
+8 = binary_data:

.EOF
