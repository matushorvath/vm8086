.EXPORT fdc_present_cylinder_units
.EXPORT fdc_present_sector_units

.EXPORT fdc_medium_changed_units
.EXPORT fdc_medium_cylinders_units
.EXPORT fdc_medium_heads_units
.EXPORT fdc_medium_sectors_units

.EXPORT fdc_image_units
.EXPORT fdc_image_index_units

# Current head positions
fdc_present_cylinder_units:
    ds  2, 0

fdc_present_sector_units:
    ds  2, 0

# Inserted floppy parameters
fdc_medium_changed_units:
    ds  2, 0

fdc_medium_cylinders_units:
    ds  2, 0

fdc_medium_heads_units:
    ds  2, 0

fdc_medium_sectors_units:
    ds  2, 0

# Floppy image pointers
fdc_image_units:
    ds  2, 0

# Floppy image indexes
fdc_image_index_units:
    ds  2, 0

.EOF
