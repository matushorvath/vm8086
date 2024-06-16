.EXPORT fdc_config_connected_units
.EXPORT fdc_config_inserted_units

##########
# Configuration information

# Is a FDD connected to this channel?
fdc_config_connected_units:
fdc_config_connected_unit0:
    db  1
fdc_config_connected_unit1:
    db  0
fdc_config_connected_unit2:
    db  0
fdc_config_connected_unit3:
    db  0

# What type of floppy is inserted?
fdc_config_inserted_units:
fdc_config_inserted_unit0:
    db  25                              # 25 = 3.5" 1.44MB
fdc_config_inserted_unit1:
    db  0
fdc_config_inserted_unit2:
    db  0
fdc_config_inserted_unit3:
    db  0

.EOF
