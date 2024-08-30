# This object will provide a fake floppy B image when no real image is specified
# TODO solve with weak symbols once linker supports them

.EXPORT floppy_b_image

floppy_b_image:
    db  0

.EOF
