PREFIX=/usr/local
SYSTEMD_SERVICES_DIRECTORY=/lib/systemd/system

# internal variables
SYSTEMD:=$(shell pgrep -c systemd)
ifeq ($(SYSTEMD), 0)
	SYSTEMD=
endif
OPENRC:=$(shell pgrep -c openrc)
ifeq ($(OPENRC), 0)
	OPENRC=
endif
INSTALL_PREFIX=$(PREFIX)/bin
systemd_substitution="s\#{{INSTALL_PREFIX}}\#$(INSTALL_PREFIX)\#g"
normal_substitution="s\#DEBUG=yes\#unset DEBUG\#\
	;s\#CONSOLE_ONLY=yes\#unset CONSOLE_ONLY\#"
normal_systemd_substitution="s\#WantedBy=multi-user.target\#WantedBy=graphical.target\#"
debug_substitution="s\#unset DEBUG\#DEBUG=yes\#"
console_substitution="s\#unset CONSOLE_ONLY\#CONSOLE_ONLY=yes\#"
console_systemd_substitution="s\#WantedBy=graphical.target\#WantedBy=multi-user.target\#"


.PHONY: install uninstall clean auto_clean console normal debug help

default: auto_clean deps notify with_mpg123 normal battery-alert.systemd battery-alert.openrc

no-mpg123: auto_clean deps notify normal battery-alert.systemd battery-alert.openrc

console: auto_clean deps with_mpg123 console-only battery-alert.systemd battery-alert.openrc

console-no-mpg123: auto_clean deps console-only battery-alert.systemd battery-alert.openrc

deps:
	@ echo -n "** Checking for essential packages ... "
	@ type head 1>/dev/null 2>&1 || ( echo "failed"; echo "  *** You must install head (probably package coreutils)"; exit 1 )
	@ type bash 1>/dev/null 2>&1 || ( echo "failed"; echo "  *** You must install bash"; exit 1 )
	@ type bc 1>/dev/null 2>&1 || ( echo "failed"; echo "  *** You must install bc (package bc)"; exit 1 )
	@ type sed 1>/dev/null 2>&1 || ( echo "failed"; echo "  *** You must install sed"; exit 1 )
	@ type gzip 1>/dev/null 2>&1 || ( echo "failed"; echo "  *** You must install gzip"; exit 1 )
	@ type pgrep 1>/dev/null 2>&1 || ( echo "failed"; echo "  *** You must install pgrep"; exit 1 )
	@ echo done

notify:
	@ echo -n "** Checking for notify-send ... "
	@ type notify-send 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install notify-send (probably package libnotify)"; exit 1 )

with_mpg123:
	@ echo -n "** Checking for mpg123 ... "
	@ type mpg123 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install mpg123 (package mpg123)"; exit 1 )


battery-alert.systemd: battery-alert.systemd.template
	@ [ -z $(SYSTEMD) ] || { \
		echo -n "Creating systemd service ... " ; \
		sed $(systemd_substitution) $< > $@ ; \
		echo done ; \
		}

battery-alert.openrc: battery-alert.openrc.template
	@ [ -z $(OPENRC) ] || { \
		echo -n "Creating openrc service ... " ; \
		sed $(systemd_substitution) $< > $@ ; \
		echo done ; \
		}

normal:
	@ sed -i $(normal_substitution) battery-alert
	@ sed -i '/^## DEBUG DATA FILE/,/^## END OF DEBUG DATA FILE/d' battery-alert
	@ sed -i $(normal_systemd_substitution) battery-alert.systemd.template
	@ if [ -e battery-alert.systemd ];then sed -i $(normal_systemd_substitution) battery-alert.systemd; fi

debug:
	@ sed -i $(debug_substitution) battery-alert
	@ sed -i '/^DEBUG=yes/ i \
## DEBUG DATA FILE \
[ -e /tmp/battery-alert.txt ] || { \
	echo "charge_percent=40" > /tmp/battery-alert-data.txt \
	echo "charge_status=Discharging" >> /tmp/battery-alert-data.txt \
} \
## END OF DEBUG DATA FILE' battery-alert

console-only:
	@ sed -i $(console_substitution) battery-alert
	@ sed -i $(console_systemd_substitution) battery-alert.systemd.template
	@ if [ -e battery-alert.systemd ];then sed -i $(console_systemd_substitution) battery-alert.systemd; fi

install:
	@ echo -n "Installing script ... "
	@ install -m 755 battery-alert $(INSTALL_PREFIX)/battery-alert
	@ echo done
	@ echo -n "Installing config ... "
	@ install -m 644 config /etc/battery-alert.conf
	@ echo done
	@ echo -n "Installing data files ... "
	@ install -m 755 -d /usr/share/battery-alert
	@ install -m 644 icons/* sounds/*.mp3 man/*.html /usr/share/battery-alert
	@ echo done
	@ if [ ! -z $(SYSTEMD) ];then \
	if [ -d $(SYSTEMD_SERVICES_DIRECTORY) ]; then \
	echo -n "Installing systemd service ... " ; \
	cp battery-alert.systemd $(SYSTEMD_SERVICES_DIRECTORY); \
	echo 'done'; \
	fi; fi
	@ echo -n "Installing man page ... "
	@ MAN=$$(man -w | sed 's/:.*//')/man1; \
	if [ ! -d "$$MAN" ]; \
	then mkdir "$$MAN" ; fi ; \
	install -m 644 man/battery-alert.1.gz "$$MAN"/battery-alert.1.gz
	@ echo done
	@ echo -n "Updating mandb ... "
	@ mandb -q
	@ echo done

uninstall:
	@ echo -n "Removing script ... "
	@ rm $(INSTALL_PREFIX)/battery-alert
	@ echo done
	@ echo -n "Removing config ... "
	@ rm /etc/battery-alert.conf
	@ echo done
	@ echo -n "Removing date files ... "
	@ rm -rf /usr/share/battery-alert
	@ echo done
	@ if [ -e $(SYSTEMD_SERVICES_DIRECTORY)/battery-alert.systemd ]; then \
	echo -n "Removing systemd service ... "; \
	rm $(SYSTEMD_SERVICES_DIRECTORY)/battery-alert.systemd; \
	echo 'done'; fi
	@ echo -n "Removing man page ... "
	@ MAN=$$(man -w | sed 's/:.*//')/man1 ; \
	rm "$$MAN"/battery-alert.1.gz
	@ echo done
	@ echo -n "Updating mandb ... "
	@ mandb -q
	@ echo done

clean:
	@echo -n "Cleaning up ... "
	@if [ -e battery-alert.systemd ]; then rm *.systemd;fi
	@if [ -e battery-alert.openrc ]; then rm *.openrc;fi
	@echo done

auto_clean:
	@if [ -e battery-alert.systemd ]; then rm *.systemd;fi
	@if [ -e battery-alert.openrc ]; then rm *.openrc;fi

help:
	@ echo "battery-alert make options:"
	@ echo ""
	@ echo "  default"
	@ echo "    Contains the default options for battery-alert."
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
	@ echo "    use this option to have battery-alert running on a non-graphical environment."
	@ echo ""
	@ echo "  console-no-mpg123"
	@ echo "    Same as above, but mpg123 would not be required."
	@ echo ""
	@ echo "Edit Makefile to match your system:"
	@ sed -n '1,/^$$/p' Makefile | sed 's/^/  /'
