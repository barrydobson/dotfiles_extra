#=============================================================================
# Dotfiles Management
#=============================================================================

# Default target
.DEFAULT_GOAL := help

# Colors for pretty output
BLUE := \033[34m
GREEN := \033[32m
RED := \033[31m
RESET := \033[0m

# Root directory to search
SUBDIR_ROOT := ./packages
SUBDIRS := $(notdir $(patsubst %/,%,$(wildcard $(SUBDIR_ROOT)/*/)))

# Optional override: pass MODULES="zsh git" on the CLI
MODULES ?=
TARGETS := $(if $(strip $(MODULES)),$(MODULES),$(SUBDIRS))

# Default stow args (override with: make STOW_ARGS="-v -t ~")
# Always target home directory explicitly
STOW_ARGS ?= -v -t $(HOME)

#=============================================================================
# Targets
#=============================================================================

.PHONY: help stow unstow clean check print-packages restow

print-packages: ## Print the list of packages to be stowed
	@echo "Directories: $(SUBDIRS)"

stow: ## Stow all packages in the packages directory to the home directory
	@test -n "$(strip $(TARGETS))" || { echo "$(RED)No packages to stow.$(RESET)"; exit 1; }
	@echo "$(BLUE)Stowing $(TARGETS)...$(RESET)"
	@cd $(SUBDIR_ROOT) && stow $(TARGETS) $(STOW_ARGS) || { echo "$(RED)Stow failed$(RESET)"; exit 1; }
	@echo "$(GREEN)✓ Dotfiles stowed successfully$(RESET)"

unstow: ## Unstow all packages in the packages directory
	@test -n "$(strip $(TARGETS))" || { echo "$(RED)No packages to unstow.$(RESET)"; exit 1; }
	@echo "$(BLUE)Unstowing $(TARGETS)...$(RESET)"
	@cd $(SUBDIR_ROOT) && stow -v -D $(TARGETS) || { echo "$(RED)Unstow failed$(RESET)"; exit 1; }
	@echo "$(GREEN)✓ Dotfiles unstowed successfully$(RESET)"

restow: unstow stow ## Restow all the packages (unstow then stow)
	@echo "$(GREEN)✓ Dotfiles restowed all successfully$(RESET)"

help: ## Display this help message
	@echo "$(BLUE)Available targets:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-15s$(RESET) %s\n", $$1, $$2}'

clean: ## Remove stow symlinks and temporary files
	@echo "$(BLUE)Cleaning up...$(RESET)"
	@find . -type l -delete
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

check: ## Check if required tools are installed
	@echo "$(BLUE)Checking requirements...$(RESET)"
	@command -v stow >/dev/null 2>&1 || { echo "$(RED)stow is not installed$(RESET)"; exit 1; }
	@echo "$(GREEN)✓ All requirements met$(RESET)"


#=============================================================================
# Development
#=============================================================================

.PHONY: lint test

lint: ## Run shellcheck on shell scripts
	@echo "$(BLUE)Running shellcheck...$(RESET)"
	@command -v shellcheck >/dev/null 2>&1 || { echo "$(RED)shellcheck is not installed$(RESET)"; exit 1; }
	@shellcheck src/**/*.sh || { echo "$(RED)Shellcheck found issues$(RESET)"; exit 1; }
	@echo "$(GREEN)✓ Shellcheck passed$(RESET)"
