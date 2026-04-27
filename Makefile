SWIFT ?= swift

.PHONY: format lint build test validate docs docs-serve \
        feature release hotfix finish-release finish-hotfix

# === Quality ===

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

# === Documentation ===

docs:
	./scripts/docs.sh

docs-serve:
	./scripts/docs.sh serve

# === GitFlow ===

feature:
	@test -n "$(name)" || (echo "Usage: make feature name=<feature-name>" && exit 1)
	./scripts/gitflow.sh feature $(name)

release:
	@test -n "$(version)" || (echo "Usage: make release version=<x.y.z>" && exit 1)
	./scripts/gitflow.sh release $(version)

hotfix:
	@test -n "$(version)" || (echo "Usage: make hotfix version=<x.y.z>" && exit 1)
	./scripts/gitflow.sh hotfix $(version)

finish-release:
	./scripts/gitflow.sh finish-release

finish-hotfix:
	./scripts/gitflow.sh finish-hotfix
