.EXPORT log_dos_function_21

# From log.s
.IMPORT log_start

# From state.s
.IMPORT reg_ah
#.IMPORT reg_ax
#.IMPORT reg_cs

#.IMPORT flag_interrupt
#.IMPORT flag_overflow
#.IMPORT flag_trap

# From libxib.a
.IMPORT print_str
.IMPORT print_num_16_b
#.IMPORT print_num_16_w

##########
log_dos_function_21:
.FRAME description, tmp
    arb -2

    call log_start

    add interrupt_log_dos_21_start_msg, 0, [rb - 1]
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
    jz  [rb + tmp], interrupt_log_dos_21_print_description

    # Yes, find description in the table
    mul [reg_ah], DOS_21_DESCRIPTION_LENGTH, [rb + description]
    add dos_21_descriptions, [rb + description], [rb + description]

interrupt_log_dos_21_print_description:
    # Print description
    add [rb + description], 0, [rb - 1]
    arb -1
    call print_str

    out 10

    arb 2
    ret 0

interrupt_log_dos_21_start_msg:
    db  "dos call: int 21h fn ", 0
.ENDFRAME

##########
.SYMBOL DOS_21_DESCRIPTION_LENGTH 48
.SYMBOL DOS_21_FUNCTION_COUNT 0x6D

dos_21_descriptions:
    db  "Program terminate", 0, "                              "        # function 00
    db  "Keyboard input with echo", 0, "                       "        # function 01
    db  "Display output", 0, "                                 "        # function 02
    db  "Wait for auxiliary device input", 0, "                "        # function 03
    db  "Auxiliary output", 0, "                               "        # function 04
    db  "Printer output", 0, "                                 "        # function 05
    db  "Direct console I/O", 0, "                             "        # function 06
    db  "Wait for direct console input without echo", 0, "     "        # function 07
    db  "Wait for console input without echo", 0, "            "        # function 08
    db  "Print string", 0, "                                   "        # function 09
    db  "Buffered keyboard input", 0, "                        "        # function 0A
    db  "Check standard input status", 0, "                    "        # function 0B
    db  "Clear keyboard buffer, invoke keyboard function", 0, ""        # function 0C
    db  "Disk reset", 0, "                                     "        # function 0D
    db  "Select disk", 0, "                                    "        # function 0E
    db  "Open file using FCB", 0, "                            "        # function 0F

    db  "Close file using FCB", 0, "                           "        # function 10
    db  "Search for first entry using FCB", 0, "               "        # function 11
    db  "Search for next entry using FCB", 0, "                "        # function 12
    db  "Delete file using FCB", 0, "                          "        # function 13
    db  "Sequential read using FCB", 0, "                      "        # function 14
    db  "Sequential write using FCB", 0, "                     "        # function 15
    db  "Create a file using FCB", 0, "                        "        # function 16
    db  "Rename file using FCB", 0, "                          "        # function 17
    db  "DOS dummy function (CP/M)", 0, "                      "        # function 18
    db  "Get current default drive", 0, "                      "        # function 19
    db  "Set disk transfer address", 0, "                      "        # function 1A
    db  "Get allocation table information", 0, "               "        # function 1B
    db  "Get allocation table info for specific device", 0, "  "        # function 1C
    db  "DOS dummy function (CP/M)", 0, "                      "        # function 1D
    db  "DOS dummy function (CP/M)", 0, "                      "        # function 1E
    db  "Get pointer to default drive parameter table", 0, "   "        # function 1F

    db  "DOS dummy function (CP/M)", 0, "                      "        # function 20
    db  "Random read using FCB", 0, "                          "        # function 21
    db  "Random write using FCB", 0, "                         "        # function 22
    db  "Get file size using FCB", 0, "                        "        # function 23
    db  "Set relative record field for FCB", 0, "              "        # function 24
    db  "Set interrupt vector", 0, "                           "        # function 25
    db  "Create new program segment", 0, "                     "        # function 26
    db  "Random block read using FCB", 0, "                    "        # function 27
    db  "Random block write using FCB", 0, "                   "        # function 28
    db  "Parse filename for FCB", 0, "                         "        # function 29
    db  "Get date", 0, "                                       "        # function 2A
    db  "Set date", 0, "                                       "        # function 2B
    db  "Get time", 0, "                                       "        # function 2C
    db  "Set time", 0, "                                       "        # function 2D
    db  "Set/reset verify switch", 0, "                        "        # function 2E
    db  "Get disk transfer address", 0, "                      "        # function 2F

    db  "Get DOS version number", 0, "                         "        # function 30
    db  "Terminate process and remain resident", 0, "          "        # function 31
    db  "Get pointer to drive parameter table", 0, "           "        # function 32
    db  "Get/set Ctrl-Break check state & get boot drive", 0, ""        # function 33
    db  "Get address to DOS critical flag", 0, "               "        # function 34
    db  "Get vector", 0, "                                     "        # function 35
    db  "Get disk free space", 0, "                            "        # function 36
    db  "Get/set switch character", 0, "                       "        # function 37
    db  "Get/set country dependent information", 0, "          "        # function 38
    db  "Create subdirectory (mkdir)", 0, "                    "        # function 39
    db  "Remove subdirectory (rmdir)", 0, "                    "        # function 3A
    db  "Change current subdirectory (chdir)", 0, "            "        # function 3B
    db  "Create file using handle", 0, "                       "        # function 3C
    db  "Open file using handle", 0, "                         "        # function 3D
    db  "Close file using handle", 0, "                        "        # function 3E
    db  "Read file or device using handle", 0, "               "        # function 3F

    db  "Write file or device using handle", 0, "              "        # function 40
    db  "Delete file", 0, "                                    "        # function 41
    db  "Move file pointer using handle", 0, "                 "        # function 42
    db  "Change file mode", 0, "                               "        # function 43
    db  "I/O control for devices (IOCTL)", 0, "                "        # function 44
    db  "Duplicate file handle", 0, "                          "        # function 45
    db  "Force duplicate file handle", 0, "                    "        # function 46
    db  "Get current directory", 0, "                          "        # function 47
    db  "Allocate memory blocks", 0, "                         "        # function 48
    db  "Free allocated memory blocks", 0, "                   "        # function 49
    db  "Modify allocated memory blocks", 0, "                 "        # function 4A
    db  "EXEC load and execute program", 0, "                  "        # function 4B
    db  "Terminate process with return code", 0, "             "        # function 4C
    db  "Get return code of a sub-process", 0, "               "        # function 4D
    db  "Find first matching file", 0, "                       "        # function 4E
    db  "Find next matching file", 0, "                        "        # function 4F

    db  "Set current process id", 0, "                         "        # function 50
    db  "Get current process id", 0, "                         "        # function 51
    db  "Get pointer to DOS INVARS", 0, "                      "        # function 52
    db  "Generate drive parameter table", 0, "                 "        # function 53
    db  "Get verify setting", 0, "                             "        # function 54
    db  "Create PSP", 0, "                                     "        # function 55
    db  "Rename file", 0, "                                    "        # function 56
    db  "Get/set file date and time using handle", 0, "        "        # function 57
    db  "Get/set memory allocation strategy", 0, "             "        # function 58
    db  "Get extended error information", 0, "                 "        # function 59
    db  "Create temporary file", 0, "                          "        # function 5A
    db  "Create new file", 0, "                                "        # function 5B
    db  "Lock/unlock file access", 0, "                        "        # function 5C
    db  "Critical error information", 0, "                     "        # function 5D
    db  "Network services", 0, "                               "        # function 5E
    db  "Network redirection", 0, "                            "        # function 5F

    db  "Get fully qualified file name", 0, "                  "        # function 60
dos_21_description_unknown:
    db  "(unknown function)", 0, "                             "
    db  "Get address of program segment prefix", 0, "          "        # function 62
    db  "Get system lead byte table", 0, "                     "        # function 63
    db  "Set device driver look ahead", 0, "                   "        # function 64
    db  "Get extended country information", 0, "               "        # function 65
    db  "Get/set global code page", 0, "                       "        # function 66
    db  "Set handle count", 0, "                               "        # function 67
    db  "Flush buffer", 0, "                                   "        # function 68
    db  "Get/set disk serial number", 0, "                     "        # function 69
    db  "DOS reserved", 0, "                                   "        # function 6A
    db  "DOS reserved", 0, "                                   "        # function 6B
    db  "Extended open/create", 0, "                           "        # function 6C

.EOF
