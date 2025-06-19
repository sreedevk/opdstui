.PHONY: all run clean

all:
	nimble build -d:ssl --threads:on

release:
	nimble build -d:release -d:ssl --threads:on

run: all
	./bin/opdstui

clean:
	nimble clean
