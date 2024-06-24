.EXPORT log_dos_21_call
.EXPORT log_dos_21_iret

# From state.s
.IMPORT reg_ax
.IMPORT reg_al
.IMPORT reg_ah
.IMPORT reg_bx
.IMPORT reg_cx
.IMPORT reg_cl
.IMPORT reg_ch
.IMPORT reg_dx
.IMPORT reg_dl
.IMPORT reg_dh
.IMPORT reg_ds
.IMPORT flag_carry
.IMPORT mem

# From util/log.s
.IMPORT log_start

# From libxib.a
.IMPORT print_str
.IMPORT print_num
.IMPORT print_num_2_b
.IMPORT print_num_16_b
.IMPORT print_num_16_w
.IMPORT print_num_radix

##########
log_dos_21_call:
.FRAME description, log_handler, tmp
    arb -3

    # TODO print where was the int 21h called (we have that saved in interrupt.s)

    call log_start

    add log_dos_21_call_start_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [reg_ah], 0, [rb - 1]
    arb -1
    call print_num_16_b

    out ':'
    out ' '

    # Do we have a function description?
    add dos_21_description_unknown, 0, [rb + description]
    lt  [reg_ah], DOS_21_FUNCTION_COUNT, [rb + tmp]
    jz  [rb + tmp], log_dos_21_call_print_description

    # Yes, find description in the table
    mul [reg_ah], DOS_21_DESCRIPTION_LENGTH, [rb + description]
    add dos_21_descriptions, [rb + description], [rb + description]

log_dos_21_call_print_description:
    # Print description
    add [rb + description], 0, [rb - 1]
    arb -1
    call print_str

    # Is there a function-specific log handler?
    add dos_21_log_handlers, [reg_ah], [ip + 1]
    add [0], 0, [rb + log_handler]

    jz  [rb + log_handler], log_dos_21_call_done

    # Yes, output the function-specific log
    call [rb + log_handler]

log_dos_21_call_done:
    out 10

    arb 3
    ret 0

log_dos_21_call_start_msg:
    db  "dos call: int 21h fn ", 0
.ENDFRAME

##########
log_dos_21_select_disk:
.FRAME
    # 0E Select disk
    add log_dos_21_select_disk_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [reg_dl], 0, [rb - 1]
    arb -1
    call print_num

    ret 0

log_dos_21_select_disk_msg:
    db  ", drive ", 0
.ENDFRAME

##########
log_dos_21_set_date:
.FRAME
    # 2B Set date
    out ','
    out ' '

    mul [reg_cx + 1], 0x100, [rb - 1]
    add [reg_cx + 0], [rb - 1], [rb - 1]
    add 10, 0, [rb - 2]
    add 4, 0, [rb - 3]
    arb -3
    call print_num_radix

    out '-'

    add [reg_dh], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out '-'

    add [reg_dl], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    ret 0
.ENDFRAME

##########
log_dos_21_set_time:
.FRAME
    # 2D Set time
    out ','
    out ' '

    add [reg_ch], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ':'

    add [reg_cl], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out ':'

    add [reg_dh], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    out '.'

    add [reg_dl], 0, [rb - 1]
    add 10, 0, [rb - 2]
    add 2, 0, [rb - 3]
    arb -3
    call print_num_radix

    ret 0
.ENDFRAME

##########
log_dos_21_open_file_handle:
.FRAME
    # 3D Open file using handle
    add log_dos_21_open_file_handle_name_msg, 0, [rb - 1]
    arb -1
    call print_str

    # Find the file name in 8086 memory and print it (ignoring the wraparound)
    # dsh1-dsh0 dsl1-dsl0
    #      dxh1-dxh0 dxl1-dxl0
    mul [reg_ds + 1], 0x10, [rb - 1]
    add [reg_dx + 1], [rb - 1], [rb - 1]
    mul [rb - 1], 0x10, [rb - 1]
    add [reg_ds + 0], [rb - 1], [rb - 1]
    mul [rb - 1], 0x10, [rb - 1]
    add [reg_dx + 0], [rb - 1], [rb - 1]
    add [mem], [rb - 1], [rb - 1]
    arb -1
    call print_str

    # Print the access mode
    add log_dos_21_open_file_handle_access_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [reg_al], 0, [rb - 1]
    arb -1
    call print_num_2_b

    ret 0

log_dos_21_open_file_handle_name_msg:
    db  ", name ", 0
log_dos_21_open_file_handle_access_msg:
    db  ", access ", 0
.ENDFRAME

##########
log_dos_21_close_file_handle:
.FRAME
    # 3E Close file using handle
    add log_dos_21_close_file_handle_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_bx + 1], 0x100, [rb - 1]
    add [reg_bx + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    ret 0

log_dos_21_close_file_handle_msg:
    db  ", handle 0x", 0
.ENDFRAME

##########
log_dos_21_read_file_handle:
.FRAME
    # 3F Read file or device using handle
    add log_dos_21_read_file_handle_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_bx + 1], 0x100, [rb - 1]
    add [reg_bx + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    add log_dos_21_read_file_handle_bytes_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_cx + 1], 0x100, [rb - 1]
    add [reg_cx + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num

    ret 0

log_dos_21_read_file_handle_msg:
    db  ", handle 0x", 0
log_dos_21_read_file_handle_bytes_msg:
    db  ", bytes ", 0
.ENDFRAME

##########
log_dos_21_force_duplicate_handle:
.FRAME
    # 46 Force duplicate file handle
    add log_dos_21_force_duplicate_handle_src_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_bx + 1], 0x100, [rb - 1]
    add [reg_bx + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    add log_dos_21_force_duplicate_handle_dst_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_cx + 1], 0x100, [rb - 1]
    add [reg_cx + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    ret 0

log_dos_21_force_duplicate_handle_src_msg:
    db  ", src handle 0x", 0
log_dos_21_force_duplicate_handle_dst_msg:
    db  ", dst handle 0x", 0
.ENDFRAME

##########
log_dos_21_exec_program:
.FRAME
    # 4B EXEC load and execute program
    add log_dos_21_exec_program_name_msg, 0, [rb - 1]
    arb -1
    call print_str

    # Find the file name in 8086 memory and print it (ignoring the wraparound)
    # dsh1-dsh0 dsl1-dsl0
    #      dxh1-dxh0 dxl1-dxl0
    mul [reg_ds + 1], 0x10, [rb - 1]
    add [reg_dx + 1], [rb - 1], [rb - 1]
    mul [rb - 1], 0x10, [rb - 1]
    add [reg_ds + 0], [rb - 1], [rb - 1]
    mul [rb - 1], 0x10, [rb - 1]
    add [reg_dx + 0], [rb - 1], [rb - 1]
    add [mem], [rb - 1], [rb - 1]
    arb -1
    call print_str

    add log_dos_21_exec_program_subfunction_msg, 0, [rb - 1]
    arb -1
    call print_str

    add [reg_al], 0, [rb - 1]
    arb -1
    call print_num

    # TODO parameter block

    ret 0

log_dos_21_exec_program_name_msg:
    db  ", name ", 0
log_dos_21_exec_program_subfunction_msg:
    db  ", subfunction ", 0
.ENDFRAME

##########
log_dos_21_iret:
.FRAME
    call log_start

    add log_dos_21_iret_ax_msg, 0, [rb - 1]
    arb -1
    call print_str

    mul [reg_ax + 1], 0x100, [rb - 1]
    add [reg_ax + 0], [rb - 1], [rb - 1]
    arb -1
    call print_num_16_w

    add log_dos_21_iret_cf_msg, 0, [rb - 1]
    arb -1
    call print_str

    add '0', [flag_carry], [rb - 1]
    out [rb - 1]

    out 10
    ret 0

log_dos_21_iret_ax_msg:
    db  "dos iret: ax=0x", 0
log_dos_21_iret_cf_msg:
    db  ", cf=", 0
.ENDFRAME

##########
.SYMBOL DOS_21_DESCRIPTION_LENGTH 48
.SYMBOL DOS_21_FUNCTION_COUNT 0x6D

dos_21_descriptions:
    db  "Program terminate", 0, "                              "        # 00
    db  "Keyboard input with echo", 0, "                       "        # 01
    db  "Display output", 0, "                                 "        # 02
    db  "Wait for auxiliary device input", 0, "                "        # 03
    db  "Auxiliary output", 0, "                               "        # 04
    db  "Printer output", 0, "                                 "        # 05
    db  "Direct console I/O", 0, "                             "        # 06
    db  "Wait for direct console input without echo", 0, "     "        # 07
    db  "Wait for console input without echo", 0, "            "        # 08
    db  "Print string", 0, "                                   "        # 09
    db  "Buffered keyboard input", 0, "                        "        # 0A
    db  "Check standard input status", 0, "                    "        # 0B
    db  "Clear keyboard buffer, invoke keyboard function", 0, ""        # 0C
    db  "Disk reset", 0, "                                     "        # 0D
    db  "Select disk", 0, "                                    "        # 0E
    db  "Open file using FCB", 0, "                            "        # 0F

    db  "Close file using FCB", 0, "                           "        # 10
    db  "Search for first entry using FCB", 0, "               "        # 11
    db  "Search for next entry using FCB", 0, "                "        # 12
    db  "Delete file using FCB", 0, "                          "        # 13
    db  "Sequential read using FCB", 0, "                      "        # 14
    db  "Sequential write using FCB", 0, "                     "        # 15
    db  "Create a file using FCB", 0, "                        "        # 16
    db  "Rename file using FCB", 0, "                          "        # 17
    db  "DOS dummy function (CP/M)", 0, "                      "        # 18
    db  "Get current default drive", 0, "                      "        # 19
    db  "Set disk transfer address", 0, "                      "        # 1A
    db  "Get allocation table information", 0, "               "        # 1B
    db  "Get allocation table info for specific device", 0, "  "        # 1C
    db  "DOS dummy function (CP/M)", 0, "                      "        # 1D
    db  "DOS dummy function (CP/M)", 0, "                      "        # 1E
    db  "Get pointer to default drive parameter table", 0, "   "        # 1F

    db  "DOS dummy function (CP/M)", 0, "                      "        # 20
    db  "Random read using FCB", 0, "                          "        # 21
    db  "Random write using FCB", 0, "                         "        # 22
    db  "Get file size using FCB", 0, "                        "        # 23
    db  "Set relative record field for FCB", 0, "              "        # 24
    db  "Set interrupt vector", 0, "                           "        # 25
    db  "Create new program segment", 0, "                     "        # 26
    db  "Random block read using FCB", 0, "                    "        # 27
    db  "Random block write using FCB", 0, "                   "        # 28
    db  "Parse filename for FCB", 0, "                         "        # 29
    db  "Get date", 0, "                                       "        # 2A
    db  "Set date", 0, "                                       "        # 2B
    db  "Get time", 0, "                                       "        # 2C
    db  "Set time", 0, "                                       "        # 2D
    db  "Set/reset verify switch", 0, "                        "        # 2E
    db  "Get disk transfer address", 0, "                      "        # 2F

    db  "Get DOS version number", 0, "                         "        # 30
    db  "Terminate process and remain resident", 0, "          "        # 31
    db  "Get pointer to drive parameter table", 0, "           "        # 32
    db  "Get/set Ctrl-Break check state & get boot drive", 0, ""        # 33
    db  "Get address to DOS critical flag", 0, "               "        # 34
    db  "Get vector", 0, "                                     "        # 35
    db  "Get disk free space", 0, "                            "        # 36
    db  "Get/set switch character", 0, "                       "        # 37
    db  "Get/set country dependent information", 0, "          "        # 38
    db  "Create subdirectory (mkdir)", 0, "                    "        # 39
    db  "Remove subdirectory (rmdir)", 0, "                    "        # 3A
    db  "Change current subdirectory (chdir)", 0, "            "        # 3B
    db  "Create file using handle", 0, "                       "        # 3C
    db  "Open file using handle", 0, "                         "        # 3D
    db  "Close file using handle", 0, "                        "        # 3E
    db  "Read file or device using handle", 0, "               "        # 3F

    db  "Write file or device using handle", 0, "              "        # 40
    db  "Delete file", 0, "                                    "        # 41
    db  "Move file pointer using handle", 0, "                 "        # 42
    db  "Change file mode", 0, "                               "        # 43
    db  "I/O control for devices (IOCTL)", 0, "                "        # 44
    db  "Duplicate file handle", 0, "                          "        # 45
    db  "Force duplicate file handle", 0, "                    "        # 46
    db  "Get current directory", 0, "                          "        # 47
    db  "Allocate memory blocks", 0, "                         "        # 48
    db  "Free allocated memory blocks", 0, "                   "        # 49
    db  "Modify allocated memory blocks", 0, "                 "        # 4A
    db  "EXEC load and execute program", 0, "                  "        # 4B
    db  "Terminate process with return code", 0, "             "        # 4C
    db  "Get return code of a sub-process", 0, "               "        # 4D
    db  "Find first matching file", 0, "                       "        # 4E
    db  "Find next matching file", 0, "                        "        # 4F

    db  "Set current process id", 0, "                         "        # 50
    db  "Get current process id", 0, "                         "        # 51
    db  "Get pointer to DOS INVARS", 0, "                      "        # 52
    db  "Generate drive parameter table", 0, "                 "        # 53
    db  "Get verify setting", 0, "                             "        # 54
    db  "Create PSP", 0, "                                     "        # 55
    db  "Rename file", 0, "                                    "        # 56
    db  "Get/set file date and time using handle", 0, "        "        # 57
    db  "Get/set memory allocation strategy", 0, "             "        # 58
    db  "Get extended error information", 0, "                 "        # 59
    db  "Create temporary file", 0, "                          "        # 5A
    db  "Create new file", 0, "                                "        # 5B
    db  "Lock/unlock file access", 0, "                        "        # 5C
    db  "Critical error information", 0, "                     "        # 5D
    db  "Network services", 0, "                               "        # 5E
    db  "Network redirection", 0, "                            "        # 5F

    db  "Get fully qualified file name", 0, "                  "        # 60
dos_21_description_unknown:
    db  "(unknown function)", 0, "                             "
    db  "Get address of program segment prefix", 0, "          "        # 62
    db  "Get system lead byte table", 0, "                     "        # 63
    db  "Set device driver look ahead", 0, "                   "        # 64
    db  "Get extended country information", 0, "               "        # 65
    db  "Get/set global code page", 0, "                       "        # 66
    db  "Set handle count", 0, "                               "        # 67
    db  "Flush buffer", 0, "                                   "        # 68
    db  "Get/set disk serial number", 0, "                     "        # 69
    db  "DOS reserved", 0, "                                   "        # 6A
    db  "DOS reserved", 0, "                                   "        # 6B
    db  "Extended open/create", 0, "                           "        # 6C

dos_21_log_handlers:
    db  0                                                               # 00 Program terminate
    db  0                                                               # 01 Keyboard input with echo
    db  0                                                               # 02 Display output
    db  0                                                               # 03 Wait for auxiliary device input
    db  0                                                               # 04 Auxiliary output
    db  0                                                               # 05 Printer output
    db  0                                                               # 06 Direct console I/O
    db  0                                                               # 07 Wait for direct console input without echo
    db  0                                                               # 08 Wait for console input without echo
    db  0                                                               # 09 Print string
    db  0                                                               # 0A Buffered keyboard input
    db  0                                                               # 0B Check standard input status
    db  0                                                               # 0C Clear keyboard buffer, invoke keyboard function
    db  0                                                               # 0D Disk reset
    db  log_dos_21_select_disk                                          # 0E Select disk
    db  0                                                               # 0F Open file using FCB

    db  0                                                               # 10 Close file using FCB
    db  0                                                               # 11 Search for first entry using FCB
    db  0                                                               # 12 Search for next entry using FCB
    db  0                                                               # 13 Delete file using FCB
    db  0                                                               # 14 Sequential read using FCB
    db  0                                                               # 15 Sequential write using FCB
    db  0                                                               # 16 Create a file using FCB
    db  0                                                               # 17 Rename file using FCB
    db  0                                                               # 18 DOS dummy function (CP/M)
    db  0                                                               # 19 Get current default drive
    db  0                                                               # 1A Set disk transfer address
    db  0                                                               # 1B Get allocation table information
    db  0                                                               # 1C Get allocation table info for specific device
    db  0                                                               # 1D DOS dummy function (CP/M)
    db  0                                                               # 1E DOS dummy function (CP/M)
    db  0                                                               # 1F Get pointer to default drive parameter table

    db  0                                                               # 20 DOS dummy function (CP/M)
    db  0                                                               # 21 Random read using FCB
    db  0                                                               # 22 Random write using FCB
    db  0                                                               # 23 Get file size using FCB
    db  0                                                               # 24 Set relative record field for FCB
    db  0                                                               # 25 Set interrupt vector
    db  0                                                               # 26 Create new program segment
    db  0                                                               # 27 Random block read using FCB
    db  0                                                               # 28 Random block write using FCB
    db  0                                                               # 29 Parse filename for FCB
    db  0                                                               # 2A Get date
    db  log_dos_21_set_date                                             # 2B Set date
    db  0                                                               # 2C Get time
    db  log_dos_21_set_time                                             # 2D Set time
    db  0                                                               # 2E Set/reset verify switch
    db  0                                                               # 2F Get disk transfer address

    db  0                                                               # 30 Get DOS version number
    db  0                                                               # 31 Terminate process and remain resident
    db  0                                                               # 32 Get pointer to drive parameter table
    db  0                                                               # 33 Get/set Ctrl-Break check state & get boot drive
    db  0                                                               # 34 Get address to DOS critical flag
    db  0                                                               # 35 Get vector
    db  0                                                               # 36 Get disk free space
    db  0                                                               # 37 Get/set switch character
    db  0                                                               # 38 Get/set country dependent information
    db  0                                                               # 39 Create subdirectory (mkdir)
    db  0                                                               # 3A Remove subdirectory (rmdir)
    db  0                                                               # 3B Change current subdirectory (chdir)
    db  0                                                               # 3C Create file using handle
    db  log_dos_21_open_file_handle                                     # 3D Open file using handle
    db  log_dos_21_close_file_handle                                    # 3E Close file using handle
    db  log_dos_21_read_file_handle                                     # 3F Read file or device using handle

    db  0                                                               # 40 Write file or device using handle
    db  0                                                               # 41 Delete file
    db  0                                                               # 42 Move file pointer using handle
    db  0                                                               # 43 Change file mode
    db  0                                                               # 44 I/O control for devices (IOCTL)
    db  0                                                               # 45 Duplicate file handle
    db  log_dos_21_force_duplicate_handle                               # 46 Force duplicate file handle
    db  0                                                               # 47 Get current directory
    db  0                                                               # 48 Allocate memory blocks
    db  0                                                               # 49 Free allocated memory blocks
    db  0                                                               # 4A Modify allocated memory blocks
    db  log_dos_21_exec_program                                         # 4B EXEC load and execute program
    db  0                                                               # 4C Terminate process with return code
    db  0                                                               # 4D Get return code of a sub-process
    db  0                                                               # 4E Find first matching file
    db  0                                                               # 4F Find next matching file

    db  0                                                               # 50 Set current process id X
    db  0                                                               # 51 Get current process id
    db  0                                                               # 52 Get pointer to DOS INVARS
    db  0                                                               # 53 Generate drive parameter table
    db  0                                                               # 54 Get verify setting
    db  0                                                               # 55 Create PSP
    db  0                                                               # 56 Rename file
    db  0                                                               # 57 Get/set file date and time using handle
    db  0                                                               # 58 Get/set memory allocation strategy
    db  0                                                               # 59 Get extended error information
    db  0                                                               # 5A Create temporary file
    db  0                                                               # 5B Create new file
    db  0                                                               # 5C Lock/unlock file access
    db  0                                                               # 5D Critical error information
    db  0                                                               # 5E Network services
    db  0                                                               # 5F Network redirection

    db  0                                                               # 60 Get fully qualified file name
    db  0
    db  0                                                               # 62 Get address of program segment prefix
    db  0                                                               # 63 Get system lead byte table
    db  0                                                               # 64 Set device driver look ahead
    db  0                                                               # 65 Get extended country information
    db  0                                                               # 66 Get/set global code page
    db  0                                                               # 67 Set handle count
    db  0                                                               # 68 Flush buffer
    db  0                                                               # 69 Get/set disk serial number
    db  0                                                               # 6A DOS reserved
    db  0                                                               # 6B DOS reserved
    db  0                                                               # 6C Extended open/create

.EOF
