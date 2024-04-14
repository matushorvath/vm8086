%include "common.inc"


section data_segment start=0x10000 nobits
    resw 29
test_ds_8:
    resw 263
test_ds_16:
    resw 1


section .text
     dump_state

    mov ax, 0x1000
    mov ds, ax

%include "add_adc_8_modes.inc"
%include "add_adc_8_numbers.inc"

     call power_off
