#BIN=/opt
#INSTALL=$(BIN)/optime
#
#install: clean | dir
#	chmod -R a+rx .
#	cp -r ./templates/* $(INSTALL)/templates
#	cp ./optime $(INSTALL)
#	cp ./*.awk $(INSTALL)
#
#dir : 
#	mkdir -p $(INSTALL)
#	mkdir -p $(INSTALL)/img
#	mkdir -p $(INSTALL)/templates
#
#clean:
#	rm -rf $(INSTALL) 
#
NAME      = "optime"
COMMAND   = optime
BUILDDIR  = build
MANDIR    = man
TEMPLATES = templates

TARGET    = bash
PREFIX    = /opt/$(COMMAND)

.PHONY: default clean build release grip test check install uninstall

default: build

#clean:
#	@gawk -f build.awk clean

build:
	@gawk -f build.awk build -target=$(TARGET)

release:
	@gawk -f build.awk build -target=$(TARGET) -type=release

#grip:
#	@gawk -f build.awk readme && grip

test: build
	@gawk -f test.awk


install: build
	@mkdir -p $(PREFIX)/bin &&\
	install $(BUILDDIR)/$(COMMAND) $(PREFIX)/bin/$(COMMAND) &&\
	mkdir -p $(PREFIX)/$(TEMPLATES) &&\
	install  $(TEMPLATES)/* $(PREFIX)/$(TEMPLATES) &&\
	echo "[OK] $(NAME) installed."

#mkdir -p $(PREFIX)/share/man/man1 &&\
#install $(MANDIR)/$(COMMAND).1 $(PREFIX)/share/man/man1/$(COMMAND).1 &&\

uninstall:
	@rm $(PREFIX)/bin/$(COMMAND) $(PREFIX)/share/man/man1/$(COMMAND).1 &&\
	echo "[OK] $(NAME) uninstalled."
