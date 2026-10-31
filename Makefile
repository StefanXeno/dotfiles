# Dev shortcuts for this repo. Tools (pre-commit, gitleaks, shellcheck, shfmt) come from mise.
SHELL_FILES := install.sh ai/sync $(wildcard test/*.sh) zsh/bin/notify-send zsh/bin/ollama-menu zsh/bin/ollama-ai zsh/bin/wt-settings zsh/bin/claude-usage zsh/bin/tmux-ai-status
STOW_PACKAGES := $(shell sed -n 's/^STOW_PACKAGES=(\(.*\))/\1/p' install.sh)

.DEFAULT_GOAL := help
.PHONY: help hooks lint fmt secrets stow rules rules-check test

help: ## Show this help
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-10s %s\n", $$1, $$2}'

hooks: ## Install the git hooks (pre-commit + pre-push)
	pre-commit install

lint: ## Run all hooks (shellcheck, shfmt, gitleaks) on every file
	pre-commit run --all-files

fmt: ## Format shell scripts with shfmt (options: .editorconfig)
	shfmt -w $(SHELL_FILES)

secrets: ## Scan the full git history and the working tree for secrets
	gitleaks git --redact --no-banner .
	gitleaks dir --redact --no-banner .

stow: ## Re-stow all packages listed in install.sh
	@for p in $(STOW_PACKAGES); do echo "stow $$p"; stow --no-folding -d "$(CURDIR)" -t "$$HOME" "$$p"; done

rules: ## Regenerate the Claude / Cursor / opencode rules from ai/
	ai/sync

rules-check: ## Fail if the generated rules are out of date
	ai/sync --check

test: ## Docker end-to-end install test
	./test/run.sh install
