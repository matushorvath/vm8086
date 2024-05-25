VMDIR = $(abspath ..)

ICDIR ?= $(abspath $(VMDIR)/../xzintbit)
include $(VMDIR)/intcode.mk

TESTDIRS = $(sort $(dir $(wildcard */Makefile)))
export TESTLOG = $(abspath test.log)

define make-each-test
	rm -rf $(TESTLOG)
	failed=0 ; \
	for testdir in $(TESTDIRS) ; do \
		$(MAKE) -C $$testdir $@ || failed=1 ; \
	done ; \
	cat test.log ; \
	[ $$failed = 0 ] || exit 1
endef

.PHONY: build
build:
	$(make-each-test)

.PHONY: test
test:
	$(make-each-test)

.PHONY: validate
validate:
	$(make-each-test)

# Clean
.PHONY: clean
clean:
	for testdir in $(TESTDIRS) ; do $(MAKE) -C $$testdir clean ; done
	rm -rf $(TESTLOG)
