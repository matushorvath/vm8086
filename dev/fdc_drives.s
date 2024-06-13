.EXPORT fdc_present_cylinder_units
.EXPORT fdc_present_sector_units

.EXPORT fdc_medium_heads_units
.EXPORT fdc_medium_tracks_units
.EXPORT fdc_medium_sectors_units

# Current head positions
fdc_present_cylinder_units:
fdc_present_cylinder_unit0:
    db  0
fdc_present_cylinder_unit1:
    db  0

fdc_present_sector_units:
fdc_present_sector_unit0:
    db  0
fdc_present_sector_unit1:
    db  0

# Inserted floppy parameters
fdc_medium_heads_units:
fdc_medium_heads_unit0:
    db  0
fdc_medium_heads_unit1:
    db  0

fdc_medium_tracks_units:
fdc_medium_tracks_unit0:
    db  0
fdc_medium_tracks_unit1:
    db  0

fdc_medium_sectors_units:
fdc_medium_sectors_unit0:
    db  0
fdc_medium_sectors_unit1:
    db  0

.EOF
