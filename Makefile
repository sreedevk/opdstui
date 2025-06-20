.PHONY: all dev install uninstall clean

all: bin/opdstui
dev:
	rm -rf bin/opdstui_dev
	nimble dev

bin/opdstui:
	nimble prod

install: bin/opdstui
	mkdir -p /usr/local/bin
	cp -f bin/opdstui /usr/local/bin/
	chmod 755 /usr/local/bin/opdstui

uninstall:
	rm -rf /usr/local/bin/opdstui

clean:
	rm -rf bin/opdstui
	rm -rf bin/opdstui_dev
