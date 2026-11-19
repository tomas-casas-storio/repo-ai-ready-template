# The single gate. Humans, CI and agents all use these targets.
# Stack-specific commands live ONLY in this file; swap them when changing stack.
.DEFAULT_GOAL := help
SHELL := bash
BASE ?= origin/main

.PHONY: help setup verify build lint typecheck format-check test guard-tests risk-tier verify-controls

help: ## List targets
	@grep -E '^[a-z-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

setup: ## Install pinned dependencies from a clean clone
	corepack enable
	pnpm install --frozen-lockfile

verify: format-check lint typecheck test build ## THE GATE: format, lint, types, tests+coverage, build

build: ## Compile
	pnpm run build

lint: ## Lint
	pnpm run lint

typecheck: ## Type check
	pnpm run typecheck

format-check: ## Check formatting
	pnpm run format:check

test: ## Unit tests with coverage threshold
	pnpm run test

guard-tests: ## Fail if tests were deleted or skipped vs BASE
	scripts/guard-tests.sh $(BASE)

risk-tier: ## Print risk tier (low|high) of the diff vs BASE
	scripts/risk-tier.sh $(BASE)

verify-controls: ## Prove GitHub-side controls are enforced (needs gh auth)
	scripts/verify-controls.sh
