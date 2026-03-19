.PHONY: run all

all: run

run: opdstui.pyz
	python opdstui.pyz

build: 
	shiv -o opdstui.pyz -e 'opdstui.cli:main' .

