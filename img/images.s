.EXPORT image_count
.EXPORT image_data
.EXPORT image_size

# TODO const MAX_IMAGE_COUNT 32

image_count:
    db  0

# Table of up to MAX_IMAGE_COUNT-1 binary images (followed by a zero-image as a terminator)

# Inflated image data
image_data:
    ds  32, 0

# Inflated image sizes
image_size:
    ds  32, 0

.EOF
