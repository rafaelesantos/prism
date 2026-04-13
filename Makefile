SWIFT ?= swift

.PHONY: format lint build test validate

format:
	./scripts/format.sh

lint:
	./scripts/lint.sh

build:
	./scripts/build.sh

test:
	./scripts/test.sh

validate:
	./scripts/validate.sh
