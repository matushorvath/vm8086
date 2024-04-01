; TODO ADC/ADD AL
; TODO ADC/ADD AX
; TODO ADC/ADD from group_immed (8 and 16 bit)

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

    mark 0x80
%include "adc_nc_8.inc"
    mark 0x81
%include "adc_c_8.inc"
    mark 0x82
%include "add_8.inc"
    mark 0x83
%include "add_adc_8_mem.inc"

    mark 0x90
%include "adc_nc_16.inc"
    mark 0x91
%include "adc_c_16.inc"
    mark 0x92
%include "add_16.inc"

    call power_off
