ICVM_TYPE ?= c

ICDIR ?= $(error ICDIR variable is not set; point it where https://github.com/matushorvath/xzintbit is cloned)

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

# Build
.PHONY: build
build: build-prep $(BINDIR)/vm6502.input

.PHONY: build-prep
build-prep:
	mkdir -p "$(BINDIR)" "$(OBJDIR)"

VM6502_OBJS = vm6502.o

$(BINDIR)/vm6502.input: $(addprefix $(OBJDIR)/, $(VM6502_OBJS)) $(LIBXIB)
	$(run-ld)

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	$(run-as)

# Clean
.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
