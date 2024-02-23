ICVM_TYPE ?= c

ICDIR ?= $(error ICDIR variable is not set; point it where https://github.com/matushorvath/xzintbit is built)
MSBASICDIR ?= $(error MSBASICDIR variable is not set; point it where https://github.com/matushorvath/msbasic is built)

ICVM ?= $(abspath $(ICDIR)/vms)/$(ICVM_TYPE)/ic
ICAS ?= $(abspath $(ICDIR)/bin/as.input)
ICLD ?= $(abspath $(ICDIR)/bin/ld.input)
ICLDMAP ?= $(abspath $(ICDIR)/bin/ldmap.input)
LIBXIB ?= $(abspath $(ICDIR)/bin/libxib.a)

SRCDIR = .
BINDIR ?= bin
OBJDIR ?= obj

define run-as
cat $^ | $(ICVM) $(ICAS) > $@ || ( cat $@ ; false )
endef

define run-ar
echo .L | cat - $^ > $@ || ( cat $@ ; false )
endef

define run-ld
echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@ || ( cat $@ ; false )
echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml || ( cat $@.map.yaml ; false )
endef

# TODO write bin2obj in intcode
define run-bin2obj
echo ".C\n$$(wc -c $^ | cut -d' ' -f1)$$(hexdump -ve '/1 ",%u"' $^)\n.R\n.I\n.E\nbinary_length:0\nbinary_data:1" > $@
endef

# Build
.PHONY: build
build: build-prep $(BINDIR)/vm6502.input $(BINDIR)/msbasic.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

VM6502_OBJS = vm6502.o arithmetic.o error.o exec.o memory.o params.o state.o util.o binary.o

$(BINDIR)/vm6502.input: $(addprefix $(OBJDIR)/, $(VM6502_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/%.o: $(SRCDIR)/const.si $(SRCDIR)/%.s
	$(run-as)

MSBASIC_OBJS = $(VM6502_OBJS) msbasic_header.o msbasic_binary.o

$(BINDIR)/msbasic.input: $(addprefix $(OBJDIR)/, $(MSBASIC_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/msbasic_binary.o: $(MSBASICDIR)/tmp/vm6502.bin
	$(run-bin2obj)

# Clean
.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
