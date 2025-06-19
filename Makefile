.PHONY: all run clean install release

all:
	nimble build -d:ssl --threads:on

release:
	nimble build -d:release -d:ssl --threads:on

install:
	nimble install -d:release -d:ssl --threads:on 

run: all
	./bin/opdstui

clean:
	nimble clean
