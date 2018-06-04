PREFIX=/usr/local
INSTALL_PREFIX=$(PREFIX)/bin

default: check_dependencies
#default: check_dependencies sng-batmon.1.gz

check_dependencies:
	@ echo -n "** Checking for head ... "
	@ type head 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install head (probably package coreutils)"; exit 1 )
	@ echo -n "** Checking for notify-send ... "
	@ type notify-send 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install notify-send (probably package libnotify)"; exit 1 )
	@ echo -n "** Checking for bc ... "
	@ type bc 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install bc (package bc)"; exit 1 )
	@ echo -n "** Checking for mpg123 ... "
	@ type umpg123 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install mpg123 (package mpg123)"; exit 1 )

#sng-batmon.1.gz:
#	@echo -n "Creating man page ... "
#	@pandoc -s -t man sng-batmon.1.md | gzip -9 > sng-batmon.1.gz
#	@echo done 

.PHONY: no-mpg123 install uninstall
#.PHONY: install uninstall clean

no-mpg123:
	@ echo -n "** Checking for head ... "
	@ type head 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install head (probably package coreutils)"; exit 1 )
	@ echo -n "** Checking for notify-send ... "
	@ type notify-send 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install notify-send (probably package libnotify)"; exit 1 )
	@ echo -n "** Checking for bc ... "
	@ type bc 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install bc (package bc)"; exit 1 )

install:
	@ echo -n "Installing script ... "
	@ install -m 755 sng-batmon $(INSTALL_PREFIX)/sng-batmon
	@ echo done
	@ echo -n "Installing config ... "
	@ install -m 644 config /etc/sng-batmon.conf
	@ echo done
	@ echo -n "Installing data files ... "
	@ install -m 755 -d /usr/share/sng-batmon
	@ install -m 644 icons/* sounds/*.mp3 man/*.html /usr/share/sng-batmon
	@ echo done
	@ echo -n "Installing man page ... "
	@ MAN=$$(man -w | sed 's/:.*//')/man1; \
	if [ ! -d "$$MAN" ]; \
	then mkdir "$$MAN" ; fi ; \
	install -m 644 man/sng-batmon.1.gz "$$MAN"/sng-batmon.1.gz
	@ echo done
	@ echo -n "Updating mandb ... "
	@ mandb -q
	@ echo done

uninstall:
	@ echo -n "Removing script ... "
	@ rm $(INSTALL_PREFIX)/sng-batmon
	@ echo done
	@ echo -n "Removing config ... "
	@ rm /etc/sng-batmon.conf
	@ echo done
	@ echo -n "Removing date files ... "
	@ rm -rf /usr/share/sng-batmon
	@ echo done
	@ echo -n "Removing man page ... "
	@ MAN=$$(man -w | sed 's/:.*//')/man1 ; \
	rm "$$MAN"/sng-batmon.1.gz
	@ echo done
	@ echo -n "Updating mandb ... "
	@ mandb -q
	@ echo done

#clean:
#	@echo -n "Cleaning up ... "
#	@rm sng-batmon.1.gz
#	@echo done
