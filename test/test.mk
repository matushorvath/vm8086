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

ifndef TESTLOG
	TESTLOG := $(shell mktemp)
endif

NAME = $(notdir $(CURDIR))

HAVE_COLOR := $(or $(FORCE_COLOR), $(shell [ -n $$(tput colors) ] && [ $$(tput colors) -ge 8 ] && echo 1))
ifeq ($(HAVE_COLOR),1)
	COLOR_NORMAL := "$(shell tput sgr0)"
	COLOR_RED := "$(shell tput setaf 1)"
	COLOR_GREEN := "$(shell tput setaf 2)"
endif

.PHONY: default test
default: test
	[ $(MAKELEVEL) -eq 0 ] && cat $(TESTLOG) && rm -f $(TESTLOG)

.PHONY: test-prep
test-prep:
	rm -rf $(RESDIR)
	mkdir -p $(RESDIR) $(OBJDIR)

$(RESDIR)/%.txt: $(OBJDIR)/%.input
	printf '$(NAME): executing ' >> $(TESTLOG)
	$(ICVM) $< > $@ 2>&1 || ( cat $@ ; true )
	@diff $(notdir $@) $@ || ( echo $(COLOR_RED)FAILED$(COLOR_NORMAL) ; diff $(notdir $@) $@ ) >> $(TESTLOG)
	@echo $(COLOR_GREEN)OK$(COLOR_NORMAL) >> $(TESTLOG)

$(OBJDIR)/%.input: $(LIB8086) $(LIBXIB) $(TEST_HEADER) $(OBJDIR)/%.o
	echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@
	echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml

$(OBJDIR)/%.o: $(OBJDIR)/%.bin
	wc -c $< | sed 's/$$/\/binary/' | cat - $< | $(ICVM) $(ICBIN2OBJ) > $@

$(OBJDIR)/%.bin $(OBJDIR)/%.lst: %.asm $(wildcard *.inc)
	nasm -f bin $< -o $@ -l $(@:.bin=.lst)
	hd $@ ; true

.PHONY: skip
skip:
	@echo $(NAME): $(COLOR_RED)SKIPPED$(COLOR_NORMAL) >> $(TESTLOG)
	false

.PHONY: clean
clean:
	rm -rf $(RESDIR) $(OBJDIR)

# Keep all automatically generated files (e.g. object files)
.SECONDARY:
