PREFIX=/usr/local
SYSTEMD_SERVICES_DIRECTORY=/lib/systemd/system

# internal variables
INSTALL_PREFIX=$(PREFIX)/bin
service_substitution="s\#{{INSTALL_PREFIX}}\#$(INSTALL_PREFIX)\#g"
normal_substitution="s\#DEBUG=yes\#unset DEBUG\#\
	;s\#CONSOLE_ONLY=yes\#unset CONSOLE_ONLY\#"
normal_service_substitution="s\#WantedBy=multi-user.target\#WantedBy=graphical.target\#"
debug_substitution="s\#unset DEBUG\#DEBUG=yes\#"
console_substitution="s\#unset CONSOLE_ONLY\#CONSOLE_ONLY=yes\#"
console_service_substitution="s\#WantedBy=graphical.target\#WantedBy=multi-user.target\#"

.PHONY: install uninstall clean auto_clean console normal debug help

default: auto_clean deps notify with_mpg123 normal sng-batmon.service

no-mpg123: auto_clean deps notify normal sng-batmon.service

console: auto_clean deps with_mpg123 console-only sng-batmon.service

console-no-mpg123: auto_clean deps console-only sng-batmon.service

deps:
	@ echo -n "** Checking for head ... "
	@ type head 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install head (probably package coreutils)"; exit 1 )
	@ echo -n "** Checking for bc ... "
	@ type bc 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install bc (package bc)"; exit 1 )
	@ echo -n "** Checking for sed ... "
	@ type osed 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install sed"; exit 1 )

notify:
	@ echo -n "** Checking for notify-send ... "
	@ type notify-send 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install notify-send (probably package libnotify)"; exit 1 )

with_mpg123:
	@ echo -n "** Checking for mpg123 ... "
	@ type mpg123 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install mpg123 (package mpg123)"; exit 1 )


sng-batmon.service: sng-batmon.service.template
	@ echo -n "Creating systemd service ... "
	@ sed $(service_substitution) $< > $@
	@ echo done

normal:
	@ sed -i $(normal_substitution) sng-batmon
	@ sed -i '/^## DEBUG DATA FILE/,/^## END OF DEBUG DATA FILE/d' sng-batmon
	@ sed -i $(normal_service_substitution) sng-batmon.service.template
	@ if [ -e sng-batmon.service ];then sed -i $(normal_service_substitution) sng-batmon.service; fi

debug:
	@ sed -i $(debug_substitution) sng-batmon
	@ sed -i '/^DEBUG=yes/ i \
## DEBUG DATA FILE \
[ -e /tmp/sng-batmon.txt ] || { \
	echo "charge_percent=40" > /tmp/sng-batmon-data.txt \
	echo "charge_status=Discharging" >> /tmp/sng-batmon-data.txt \
} \
## END OF DEBUG DATA FILE' sng-batmon

console-only:
	@ sed -i $(console_substitution) sng-batmon
	@ sed -i $(console_service_substitution) sng-batmon.service.template
	@ if [ -e sng-batmon.service ];then sed -i $(console_service_substitution) sng-batmon.service; fi

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
	@ if [ -e sng-batmon.service ];then \
	if [ -d $(SYSTEMD_SERVICES_DIRECTORY) ]; then \
	echo -n "Installing systemd service ... " ; \
	cp sng-batmon.service $(SYSTEMD_SERVICES_DIRECTORY); \
	echo 'done'; \
	fi; fi
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
	@ if [ -e $(SYSTEMD_SERVICES_DIRECTORY)/sng-batmon.service ]; then \
	echo -n "Removing systemd service ... "; \
	rm $(SYSTEMD_SERVICES_DIRECTORY)/sng-batmon.service; \
	echo 'done'; fi
	@ echo -n "Removing man page ... "
	@ MAN=$$(man -w | sed 's/:.*//')/man1 ; \
	rm "$$MAN"/sng-batmon.1.gz
	@ echo done
	@ echo -n "Updating mandb ... "
	@ mandb -q
	@ echo done

clean:
	@echo -n "Cleaning up ... "
	@if [ -e sng-batmon.service ]; then rm *.service;fi
	@echo done

auto_clean:
	@if [ -e sng-batmon.service ]; then rm *.service;fi

help:
	@ echo "sng-batmon make options:"
	@ echo ""
	@ echo "  default"
	@ echo "    Contains the default options for sng-batmon."
	@ echo "    These are the options used when make is executed without any arguments."
	@ echo "    Options description:"
	@ echo "      1. make sure essential packages are already installed"
	@ echo "      2. make sure notify-send executable is already installed"
	@ echo "      3. make sure mpg123 executable is already installed"
	@ echo "      4. make sure systemd service is up to date"
	@ echo ""
	@ echo "  no-mpg123"
	@ echo "    Do not require mpg123 to be installed."
	@ echo ""
	@ echo "  console"
	@ echo "    This option will disable visual notification. In other words, one would"
	@ echo "    use this option to have sng-batmon running on a non-graphical environment."
	@ echo ""
	@ echo "  console-no-mpg123"
	@ echo "    Same as above, but mpg123 would not be required."
	@ echo ""
	@ echo "Edit Makefile to match your system:"
	@ sed -n '1,2p' Makefile | sed 's/^/  /'
