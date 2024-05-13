# VM state information derived from the SingleStepTests JSON format

.EXPORT test_header_end

.EXPORT init_ax
.EXPORT init_bx
.EXPORT init_cx
.EXPORT init_dx
.EXPORT init_cs
.EXPORT init_ss
.EXPORT init_ds
.EXPORT init_es
.EXPORT init_sp
.EXPORT init_bp
.EXPORT init_si
.EXPORT init_di
.EXPORT init_ip
.EXPORT init_flags

.EXPORT init_mem_length
.EXPORT result_mem_length
.EXPORT mem_data

# Initial register values, they point into the data immediate after this object
+00 = init_ax:
+01 = init_bx:
+02 = init_cx:
+03 = init_dx:
+04 = init_cs:
+05 = init_ss:
+06 = init_ds:
+07 = init_es:
+08 = init_sp:
+09 = init_bp:
+10 = init_si:
+11 = init_di:
+12 = init_ip:
+13 = init_flags:

# Number of memory initialization records
+14 = init_mem_length:

# Number of memory output records
+15 = result_mem_length:

# End of fixed test header (not counting init_mem_data)
+15 = test_header_end:

# Initialization and result record data
+16 = mem_data:

.EOF
