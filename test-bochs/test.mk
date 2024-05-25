VMDIR = $(abspath ../..)

ICDIR ?= $(abspath ../../../xzintbit)
include $(VMDIR)/intcode.mk

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

LIBCPU = $(VMDIR)/bin/libcpu.a

HAVE_COLOR := $(or $(FORCE_COLOR), $(shell [ -n $$(tput colors) ] && [ $$(tput colors) -ge 8 ] && echo 1))
ifeq ($(HAVE_COLOR),1)
	COLOR_NORMAL := "$$(tput sgr0)"
	COLOR_RED := "$$(tput setaf 1)"
	COLOR_GREEN := "$$(tput setaf 2)"
	COLOR_YELLOW := "$$(tput setaf 3)"
endif

define passed
	echo $(COLOR_GREEN)PASSED$(COLOR_NORMAL) >> $(TESTLOG)
endef

define failed
	( echo $(COLOR_RED)FAILED$(COLOR_NORMAL) ; false ) >> $(TESTLOG)
endef

define disabled
	echo $(COLOR_YELLOW)DISABLED$(COLOR_NORMAL) >> $(TESTLOG)
endef

define failed-diff
	( echo $(COLOR_RED)FAILED$(COLOR_NORMAL) ; diff $(SAMPLE_TXT) $@ ; false ) >> $(TESTLOG)
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

.PHONY: build
build: test-prep $(OBJDIR)/$(NAME).bochs.bin $(OBJDIR)/$(NAME).input
	[ $(MAKELEVEL) -eq 0 ] && cat $(TESTLOG) && rm -f $(TESTLOG) || true

.PHONY: test-prep
test-prep:
	mkdir -p $(RESDIR) $(OBJDIR) $(COMMON_OBJDIR) $(COMMON_BINDIR)

# Test the vm8086 binary
$(RESDIR)/%.vm8086.txt: $(OBJDIR)/%.input FORCE
	printf '$(NAME): [vm8086] executing ' >> $(TESTLOG)
	rm -f $@
	$(ICVM) $< > $@ 2>&1 || ( cat $@ ; true )
	diff $(SAMPLE_TXT) $@ || $(failed-diff)
	@$(passed)

TEST_OBJS = $(COMMON_OBJDIR)/main.o $(COMMON_OBJDIR)/bochs_api.o $(COMMON_OBJDIR)/config.o \
	$(COMMON_OBJDIR)/devices.o $(COMMON_OBJDIR)/dump_state.o $(COMMON_OBJDIR)/test_api.o \
	$(LIBCPU) $(LIBXIB) $(COMMON_OBJDIR)/binary_header.o

$(OBJDIR)/%.input: $(TEST_OBJS) $(OBJDIR)/%.o
	printf '$(NAME): [intcode] linking ' >> $(TESTLOG)
	echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@ || $(failed)
	echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml || $(failed)
	@$(passed)

$(OBJDIR)/%.o: $(OBJDIR)/%.vm8086.bin
	printf '$(NAME): [intcode] bin2obj ' >> $(TESTLOG)
	wc -c $< | sed 's/$$/\/binary/' | cat - $< | $(ICVM) $(ICBIN2OBJ) > $@ || $(failed)
	@$(passed)

# Test the bochs binary
ifeq ($(DISABLE_BOCHS), 1)
$(RESDIR)/%.bochs.txt:
	printf '$(NAME): [bochs] validating ' >> $(TESTLOG)
	echo "bochs test disabled" > $@
	$(disabled)
else
$(RESDIR)/%.bochs.txt: $(RESDIR)/%.bochs.data $(COMMON_BINDIR)/bochs_output
	printf '$(NAME): [bochs] validating ' >> $(TESTLOG)
	rm -f $@
	$(COMMON_BINDIR)/bochs_output $< $@ || $(failed)
	diff $(SAMPLE_TXT) $@ || $(failed-diff)
	@$(passed)
endif

$(RESDIR)/%.bochs.data: $(OBJDIR)/%.bochs.bin FORCE
	printf '$(NAME): [bochs] executing ' >> $(TESTLOG)
	bochs -q -f $(COMMON_DIR)/bochsrc.${PLATFORM} -rc $(COMMON_DIR)/bochs.debugger \
		"optromimage1:file=$<,address=0xca000" | tee $(patsubst %.data,%.stdout,$@)
	grep '^>>>.*<<<$$' $(patsubst %.data,%.stdout,$@) > $@
	@$(passed)

# Build the binaries
$(OBJDIR)/%.bochs.bin: %.asm $(wildcard *.inc) $(wildcard $(COMMON_DIR)/*.inc) $(COMMON_BINDIR)/checksum
	printf '$(NAME): [bochs] assembling ' >> $(TESTLOG)
	nasm -i $(COMMON_DIR) -d BOCHS -f bin $< -o $@ || $(failed)
	$(COMMON_BINDIR)/checksum $@ || rm $@
	# hexdump -C $@ ; true
	[ "$$(wc -c < $@)" -eq 90112 ] || $(failed)
	@$(passed)

$(OBJDIR)/%.vm8086.bin: %.asm $(wildcard *.inc) $(wildcard $(COMMON_DIR)/*.inc)
	printf '$(NAME): [vm8086] assembling ' >> $(TESTLOG)
	nasm -i $(COMMON_DIR) -d VM8086 -f bin $< -o $@ || $(failed)
	# hexdump -C $@ ; true
	[ "$$(wc -c < $@)" -eq 221184 ] || ( rm $@ ; $(failed) )
	@$(passed)

# Build supporting tools and common sources
$(COMMON_BINDIR)/%: $(COMMON_OBJDIR)/%.o
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(COMMON_OBJDIR)/%.o: $(COMMON_DIR)/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $^ -o $@

$(COMMON_OBJDIR)/%.o: $(COMMON_DIR)/%.s
	$(run-intcode-as)

# Clean
.PHONY: clean
clean:
	rm -rf $(RESDIR) $(OBJDIR) $(COMMON_OBJDIR) $(COMMON_BINDIR)

# Keep all automatically generated files (e.g. object files)
.SECONDARY:

# Force a rebuild by depending on this target
.PHONY: FORCE
FORCE:
