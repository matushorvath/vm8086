; TODO ADC/ADD AL
; TODO ADC/ADD AX
; TODO ADC/ADD from group_immed (8 and 16 bit)

%include "common.inc"


; section data_segment start=0x10000 nobits
;     resw 29
; test_ds_8:
;     resw 263
; test_ds_16:
;     resw 1


section .text
     dump_state

;     mov ax, 0x1000
;     mov ds, ax

;     mark 0x80
; %include "adc_nc_8.inc"
;     mark 0x81
; %include "adc_c_8.inc"
;     mark 0x82
; %include "add_8.inc"
;     mark 0x83
; %include "add_adc_8_mem.inc"

;     mark 0x90
; %include "adc_nc_16.inc"
;     mark 0x91
; %include "adc_c_16.inc"
;     mark 0x92
; %include "add_16.inc"

; TODO select specific numbers to test + semi-random selection, don't test the whole range
%include "add_adc_8_all.inc"
; %include "add_adc_16_all.inc"

     call power_off


; section .data start=data_addr

; parity:
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
;     db  1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1
