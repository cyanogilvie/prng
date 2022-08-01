DESTDIR=/usr/local
PACKAGE_NAME=prng
VER=0.7
TCLSH=tclsh

all: tm docs

tm/$(PACKAGE_NAME)-$(VER).tm: baseseq.tcl
	mkdir -p tm
	cp baseseq.tcl tm/$(PACKAGE_NAME)-$(VER).tm

tm/$(PACKAGE_NAME)/blowfish-$(VER).tm: blowfish.tcl
	mkdir -p tm/$(PACKAGE_NAME)
	cp blowfish.tcl $@

tm/$(PACKAGE_NAME)/mt-$(VER).tm: mt.tcl
	mkdir -p tm/$(PACKAGE_NAME)
	cp mt.tcl $@

tm: tm/$(PACKAGE_NAME)-$(VER).tm tm/$(PACKAGE_NAME)/blowfish-$(VER).tm tm/$(PACKAGE_NAME)/mt-$(VER).tm

docs: doc/$(PACKAGE_NAME).n README.md

install-tm: tm
	mkdir -p $(DESTDIR)/lib/tcl8/site-tcl/$(PACKAGE_NAME)
	cp tm/$(PACKAGE_NAME)-$(VER).tm $(DESTDIR)/lib/tcl8/site-tcl/
	cp tm/$(PACKAGE_NAME)/blowfish-$(VER).tm $(DESTDIR)/lib/tcl8/site-tcl/$(PACKAGE_NAME)/
	cp tm/$(PACKAGE_NAME)/mt-$(VER).tm $(DESTDIR)/lib/tcl8/site-tcl/$(PACKAGE_NAME)/

install-doc: docs
	mkdir -p $(DESTDIR)/man
	cp doc/$(PACKAGE_NAME).n $(DESTDIR)/man/

install: install-tm install-doc

clean:
	rm -r tm

README.md: doc/$(PACKAGE_NAME).md
	pandoc --standalone --from markdown --to gfm doc/$(PACKAGE_NAME).md --output README.md

doc/$(PACKAGE_NAME).n: doc/$(PACKAGE_NAME).md
	pandoc --standalone --from markdown --to man doc/$(PACKAGE_NAME).md --output doc/$(PACKAGE_NAME).n

test: tm
	$(TCLSH) tests/all.tcl $(TESTFLAGS) -load "source [file join $$::tcltest::testsDirectory .. tm $(PACKAGE_NAME)-$(VER).tm]; package provide $(PACKAGE_NAME) $(VER); source [file join $$::tcltest::testsDirectory .. tm $(PACKAGE_NAME) blowfish-$(VER).tm]; package provide $(PACKAGE_NAME)::blowfish $(VER); source [file join $$::tcltest::testsDirectory .. tm $(PACKAGE_NAME) mt-$(VER).tm]; package provide $(PACKAGE_NAME)::mt $(VER)"

.PHONY: all clean install install-tm install-doc docs test tm
