all: install

.PHONY: install format-code frontend dist

install:
	poetry install

format-code:
	poetry run black elevation/**/*.py

frontend:
	docker build -t orienteer-frontend -f Dockerfile.frontend .

dist:
	scripts/frontend-dist