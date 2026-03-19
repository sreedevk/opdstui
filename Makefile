.PHONY: run all

SRC := src/opdstui/*.py

all: run

run: opdstui.pyz
	@echo "Running..."
	uv run opdstui.pyz

build: $(SRC)
	shiv -o opdstui.pyz -e 'opdstui.cli:main' .

dev: main.py
	uv run main.py
