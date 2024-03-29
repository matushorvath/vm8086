ICVM_TYPE ?= c

ICDIR ?= $(abspath ../../../xzintbit)
VMDIR ?= $(abspath ../..)

ifeq ($(shell test -d $(ICDIR) || echo error),error)
	$(error ICDIR variable is invalid; point it where https://github.com/matushorvath/xzintbit is built)
endif

ICVM ?= $(abspath $(ICDIR)/vms)/$(ICVM_TYPE)/ic
ICAS ?= $(abspath $(ICDIR)/bin/as.input)
ICBIN2OBJ ?= $(abspath $(ICDIR)/bin/bin2obj.input)
ICLD ?= $(abspath $(ICDIR)/bin/ld.input)
ICLDMAP ?= $(abspath $(ICDIR)/bin/ldmap.input)
LIBXIB ?= $(abspath $(ICDIR)/bin/libxib.a)

LIB8086 ?= $(abspath $(VMDIR)/bin/lib8086.a)
TEST_HEADER ?= $(abspath $(VMDIR)/obj/test_header.o)

RESDIR ?= res
OBJDIR ?= obj

COMMON_DIR ?= $(abspath ../common)
COMMON_OBJDIR ?= $(abspath ../common/obj)
COMMON_BINDIR ?= $(abspath ../common/bin)

ifndef TESTLOG
	TESTLOG := $(shell mktemp)
endif

NAME = $(notdir $(CURDIR))

SAMPLE_TXT := $(NAME).txt
VM8086_TXT := $(patsubst %.txt,$(RESDIR)/%.vm8086.txt,$(SAMPLE_TXT))
BOCHS_TXT := $(patsubst %.txt,$(RESDIR)/%.bochs.txt,$(SAMPLE_TXT))

HAVE_COLOR := $(or $(FORCE_COLOR), $(shell [ -n $$(tput colors) ] && [ $$(tput colors) -ge 8 ] && echo 1))
ifeq ($(HAVE_COLOR),1)
	COLOR_NORMAL := "$$(tput sgr0)"
	COLOR_RED := "$$(tput setaf)"
	COLOR_GREEN := "$$(tput setaf 2)"
endif

define passed
	echo $(COLOR_GREEN)PASSED$(COLOR_NORMAL) >> $(TESTLOG)
endef

define failed
	( echo $(COLOR_RED)FAILED$(COLOR_NORMAL) ; false ) >> $(TESTLOG)
endef

define failed-diff
	( echo $(COLOR_RED)FAILED$(COLOR_NORMAL) ; diff $(SAMPLE_TXT) $@ ) >> $(TESTLOG)
endef

ifeq ($(OS), Windows_NT)
	PLATFORM := windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		PLATFORM := linux
	endif
	ifeq ($(UNAME_S), Darwin)
		PLATFORM := macos
	endif
endif

.PHONY: test
test: test-prep $(VM8086_TXT)
	[ $(MAKELEVEL) -eq 0 ] && cat $(TESTLOG) && rm -f $(TESTLOG) || true

.PHONY: validate
validate: test-prep $(BOCHS_TXT)
	[ $(MAKELEVEL) -eq 0 ] && cat $(TESTLOG) && rm -f $(TESTLOG) || true

.PHONY: all
all: test-prep $(BOCHS_TXT) $(VM8086_TXT)
	[ $(MAKELEVEL) -eq 0 ] && cat $(TESTLOG) && rm -f $(TESTLOG) || true

.PHONY: test-prep
test-prep:
	rm -rf $(RESDIR)
	mkdir -p $(RESDIR) $(OBJDIR) $(COMMON_OBJDIR) $(COMMON_BINDIR)

# Test the vm8086 binary
$(RESDIR)/%.vm8086.txt: $(OBJDIR)/%.input
	printf '$(NAME): [vm8086] executing ' >> $(TESTLOG)
	$(ICVM) $< > $@ 2>&1 || ( cat $@ ; true )
	diff $(SAMPLE_TXT) $@ || $(failed-diff)
	@$(passed)

$(OBJDIR)/%.input: $(LIB8086) $(LIBXIB) $(TEST_HEADER) $(OBJDIR)/%.o
	printf '$(NAME): [intcode] linking ' >> $(TESTLOG)
	echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@ || $(failed)
	echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml || $(failed)
	@$(passed)

$(OBJDIR)/%.o: $(OBJDIR)/%.vm8086.bin
	printf '$(NAME): [intcode] bin2obj ' >> $(TESTLOG)
	wc -c $< | sed 's/$$/\/binary/' | cat - $< | $(ICVM) $(ICBIN2OBJ) > $@ || $(failed)
	@$(passed)

# Test the bochs binary
$(RESDIR)/%.bochs.txt: $(OBJDIR)/%.bochs.serial $(COMMON_BINDIR)/dump_state
	printf '$(NAME): [bochs] generating output ' >> $(TESTLOG)
	$(COMMON_BINDIR)/dump_state $< $@
	diff $(SAMPLE_TXT) $@ || $(failed-diff)
	@$(passed)

$(OBJDIR)/%.bochs.serial: $(OBJDIR)/%.bochs.bin
	printf '$(NAME): [bochs] executing ' >> $(TESTLOG)
	echo continue | bochs -q -f ../common/bochsrc.${PLATFORM} \
		"optromimage1:file=$<,address=0xd0000" "com1:dev=$@" || true
	touch $@
	@$(passed)

# Build the binaries
$(OBJDIR)/%.bochs.bin: %.asm $(wildcard *.inc) $(COMMON_BINDIR)/checksum
	printf '$(NAME): [bochs] assembling ' >> $(TESTLOG)
	nasm -i ../common -d BOCHS -f bin $< -o $@ || $(failed)
	$(COMMON_BINDIR)/checksum $@ || rm $@
	hexdump -C $@ ; true
	@$(passed)

$(OBJDIR)/%.vm8086.bin: %.asm $(wildcard *.inc)
	printf '$(NAME): [vm8086] assembling ' >> $(TESTLOG)
	nasm -i ../common -d VM8086 -f bin $< -o $@ || $(failed)
	hexdump -C $@ ; true
	@$(passed)

# Build supporting tools
$(COMMON_BINDIR)/%: $(COMMON_OBJDIR)/%.o
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(COMMON_OBJDIR)/%.o: $(COMMON_DIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $^ -o $@

# Clean
.PHONY: clean
clean:
	rm -rf $(RESDIR) $(OBJDIR) $(COMMON_OBJDIR) $(COMMON_BINDIR)

# Keep all automatically generated files (e.g. object files)
.SECONDARY:
