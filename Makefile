SWIFT ?= swift
SHELL := /bin/bash

.PHONY: menu format lint build test validate coverage clean \
        feature release hotfix finish-release finish-hotfix help

# ── Colors ──────────────────────────────────────────────

ORANGE  := \033[38;2;255;92;0m
DIM     := \033[2m
BOLD    := \033[1m
RESET   := \033[0m
GREEN   := \033[32m
RED     := \033[31m
CYAN    := \033[36m

define header
	@printf "\n$(ORANGE)$(BOLD)%-60s$(RESET)\n" "$(1)"
	@printf "$(DIM)────────────────────────────────────────────────────────────$(RESET)\n"
endef

define step
	@printf "  $(DIM)>$(RESET) $(1)... "
endef

define done
	@printf "$(GREEN)done$(RESET)\n"
endef

define fail
	@printf "$(RED)failed$(RESET)\n"
endef

# ── Interactive Menu ────────────────────────────────────

menu:
	@printf "\n$(ORANGE)$(BOLD)  Prism$(RESET)$(DIM) — development toolkit$(RESET)\n\n"
	@printf "  $(BOLD)Quality$(RESET)\n"
	@printf "    $(CYAN)make format$(RESET)     auto-format sources\n"
	@printf "    $(CYAN)make lint$(RESET)       strict lint check\n"
	@printf "    $(CYAN)make build$(RESET)      build all targets\n"
	@printf "    $(CYAN)make test$(RESET)       run tests + coverage\n"
	@printf "    $(CYAN)make validate$(RESET)   full pipeline (lint > build > test)\n"
	@printf "    $(CYAN)make coverage$(RESET)   generate coverage report\n"
	@printf "    $(CYAN)make clean$(RESET)      remove build artifacts\n"
	@printf "\n"
	@printf "  $(BOLD)GitFlow$(RESET)\n"
	@printf "    $(CYAN)make feature name=xyz$(RESET)       create feature branch\n"
	@printf "    $(CYAN)make release version=1.0.0$(RESET)  create release branch\n"
	@printf "    $(CYAN)make hotfix  version=1.0.1$(RESET)  create hotfix branch\n"
	@printf "    $(CYAN)make finish-release$(RESET)         merge release to main\n"
	@printf "    $(CYAN)make finish-hotfix$(RESET)          merge hotfix to main\n"
	@printf "\n"

# ── Quality ─────────────────────────────────────────────

format:
	$(call header,FORMAT)
	$(call step,formatting Package.swift)
	@$(SWIFT) format format --in-place --parallel Package.swift 2>/dev/null && $(call done) || $(call fail)
	$(call step,formatting Sources + Tests)
	@$(SWIFT) format format --in-place --parallel --recursive Sources Tests 2>/dev/null && $(call done) || $(call fail)

lint:
	$(call header,LINT)
	$(call step,checking Package.swift)
	@$(SWIFT) format lint --strict --parallel Package.swift && $(call done) || ($(call fail) && exit 1)
	$(call step,checking Sources + Tests)
	@$(SWIFT) format lint --strict --parallel --recursive Sources Tests && $(call done) || ($(call fail) && exit 1)

build:
	$(call header,BUILD)
	$(call step,resolving dependencies)
	@$(SWIFT) package resolve 2>/dev/null && $(call done) || $(call fail)
	$(call step,compiling all targets)
	@$(SWIFT) build --build-tests --explicit-target-dependency-import-check error 2>&1 | tail -1 && $(call done) || ($(call fail) && exit 1)

test:
	$(call header,TEST)
	@mkdir -p .build/artifacts
	$(call step,running test suites)
	@$(SWIFT) test \
		--enable-code-coverage \
		--xunit-output .build/artifacts/test-results.xml \
		--explicit-target-dependency-import-check error 2>&1 | \
		grep -E "^(Test|Build|.*passed|.*failed|.*test)" | tail -5
	@printf "\n"
	@$(MAKE) --no-print-directory _coverage-summary

coverage:
	$(call header,COVERAGE)
	@./scripts/coverage.sh

_coverage-summary:
	@BIN=$$($(SWIFT) build --show-bin-path) && \
	COV_FILE="$${BIN}/../codecov/default.profdata" && \
	if [ -f "$$COV_FILE" ]; then \
		EXEC=$$(find $$BIN -name "*.xctest" -o -name "PrismPackageTests" 2>/dev/null | head -1) && \
		if [ -n "$$EXEC" ]; then \
			REPORT=$$(xcrun llvm-cov report "$$EXEC" -instr-profile="$$COV_FILE" -ignore-filename-regex=".build|Tests" 2>/dev/null) && \
			TOTAL=$$(echo "$$REPORT" | grep "TOTAL" | awk '{print $$NF}') && \
			printf "  $(BOLD)coverage$(RESET) %s\n" "$$TOTAL"; \
		fi; \
	else \
		printf "  $(DIM)run 'make test' first to generate coverage data$(RESET)\n"; \
	fi

validate:
	$(call header,VALIDATE)
	@printf "  $(DIM)lint > build > test$(RESET)\n\n"
	@$(MAKE) --no-print-directory lint
	@$(MAKE) --no-print-directory build
	@$(MAKE) --no-print-directory test
	$(call header,RESULT)
	@printf "  $(GREEN)$(BOLD)all checks passed$(RESET)\n\n"

clean:
	$(call header,CLEAN)
	$(call step,removing .build)
	@rm -rf .build
	$(call done)

# ── GitFlow ─────────────────────────────────────────────

feature:
	@test -n "$(name)" || (printf "  $(RED)usage: make feature name=<name>$(RESET)\n" && exit 1)
	$(call header,FEATURE)
	$(call step,creating feature/$(name))
	@./scripts/gitflow.sh feature $(name) && $(call done) || ($(call fail) && exit 1)

release:
	@test -n "$(version)" || (printf "  $(RED)usage: make release version=<x.y.z>$(RESET)\n" && exit 1)
	$(call header,RELEASE)
	$(call step,creating release/$(version))
	@./scripts/gitflow.sh release $(version) && $(call done) || ($(call fail) && exit 1)

hotfix:
	@test -n "$(version)" || (printf "  $(RED)usage: make hotfix version=<x.y.z>$(RESET)\n" && exit 1)
	$(call header,HOTFIX)
	$(call step,creating hotfix/$(version))
	@./scripts/gitflow.sh hotfix $(version) && $(call done) || ($(call fail) && exit 1)

finish-release:
	$(call header,FINISH RELEASE)
	@./scripts/gitflow.sh finish-release

finish-hotfix:
	$(call header,FINISH HOTFIX)
	@./scripts/gitflow.sh finish-hotfix

# ── Help ────────────────────────────────────────────────

help: menu
