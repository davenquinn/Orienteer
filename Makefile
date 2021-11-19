all: install

.PHONY: install format-code

install:
	poetry install

format-code:
	poetry run black elevation/**/*.py