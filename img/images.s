.EXPORT floppy_image
.EXPORT floppy_data
.EXPORT floppy_size

# TODO const FLOPPY_COUNT 16

# Table of FLOPPY_COUNT-1 binary floppy images (followed by a zero-image as a terminator)

# Deflated floppy image pointers, invalid after initialization
floppy_image:
    ds  16, 0

# Inflated floppy data
floppy_data:
    ds  16, 0

# Inflated floppy size
floppy_size:
    ds  16, 0

.EOF
