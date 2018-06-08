PREFIX=/usr/local
INSTALL_PREFIX=$(PREFIX)/bin
service_substitution="s\#{{INSTALL_PREFIX}}\#$(INSTALL_PREFIX)\#g"
visual_substitution="s\#DEBUG=yes\#unset DEBUG\#\
	;s\#CONSOLE_ONLY=yes\#unset CONSOLE_ONLY\#"
visual_service_substitution="s\#WantedBy=multi-user.target\#WantedBy=graphical.target\#"
debug_substitution="s\#unset DEBUG\#DEBUG=yes\#"
console_substitution="s\#unset CONSOLE_ONLY\#CONSOLE_ONLY=yes\#"
console_service_substitution="s\#WantedBy=graphical.target\#WantedBy=multi-user.target\#"

.PHONY: install uninstall clean auto_clean console visual debug

default: auto_clean deps notify with_mpg123 visual sng-batmon.service

no-mpg123: auto_clean deps notify visual sng-batmon.service

console: auto_clean deps with_mpg123 console-only sng-batmon.service

console-no-mpg123: auto_clean deps console-only sng-batmon.service

deps:
	@ echo -n "** Checking for head ... "
	@ type head 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install head (probably package coreutils)"; exit 1 )
	@ echo -n "** Checking for bc ... "
	@ type bc 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install bc (package bc)"; exit 1 )

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

visual:
	@ sed -i $(visual_substitution) sng-batmon
	@ sed -i $(visual_service_substitution) sng-batmon.service.template
	@ if [ -e sng-batmon.service ];then sed -i $(visual_service_substitution) sng-batmon.service; fi

debug:
	@ sed -i $(debug_substitution) sng-batmon

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

clean:
	@echo -n "Cleaning up ... "
	@if [ -e sng-batmon.service ]; then rm *.service;fi
	@echo done

auto_clean:
	@if [ -e sng-batmon.service ]; then rm *.service;fi
