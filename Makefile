PREFIX ?= /usr/local

install:
	@mkdir -p $(PREFIX)/bin
	@cp bin/diskdoc $(PREFIX)/bin/diskdoc
	@chmod +x $(PREFIX)/bin/diskdoc
	@echo "diskdoc installed to $(PREFIX)/bin/diskdoc"

uninstall:
	@rm -f $(PREFIX)/bin/diskdoc
	@echo "diskdoc uninstalled"

lint:
	@shellcheck bin/diskdoc

.PHONY: install uninstall lint
