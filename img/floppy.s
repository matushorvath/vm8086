.EXPORT floppy_count
.EXPORT floppy_data
.EXPORT floppy_size

# TODO const MAX_FLOPPY_COUNT 16

floppy_count:
    db  0

# Table of up to MAX_FLOPPY_COUNT-1 binary floppy images (followed by a zero-image as a terminator)

# Inflated floppy data
floppy_data:
    ds  16, 0

# Inflated floppy size
floppy_size:
    ds  16, 0

.EOF
