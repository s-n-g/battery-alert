PREFIX=/usr/local
INSTALL_PREFIX=$(PREFIX)/bin

default: check_programs sng-batmon.1.gz
	
check_programs:
	@echo -n "** Checking for notify-send ... "
	@type notify-send 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install notify-send (probably package libnotify)"; exit 1 )
	@echo -n "** Checking for bc ... "
	@type bc 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install bc (package bc)"; exit 1 )
	@echo -n "** Checking for mpg123 ... "
	@type mpg123 1>/dev/null 2>&1 && echo found || ( echo "not found"; echo "  *** You must install mpg123 (package mpg123)"; exit 1 )

sng-batmon.1.gz:
	@echo -n "Creating man page ... "
	@pandoc -s -t man sng-batmon.1.md | gzip -9 > sng-batmon.1.gz
	@echo done 

.PHONY: install uninstall clean

install:
	install -m 755 sng-batmon $(INSTALL_PREFIX)/sng-batmon
	install -m 644 config /etc/sng-batmon.conf
	install -m 755 -d /usr/share/sng-batmon
	install -m 644 icons/* sounds/*.mp3 /usr/share/sng-batmon

uninstall:
	rm $(INSTALL_PREFIX)/sng-batmon
	rm /etc/sng-batmon.conf
	rm -rf /usr/share/sng-batmon
	
clean:
	@echo -n "Cleaning up ... "
	@rm sng-batmon.1.gz
	@echo done
