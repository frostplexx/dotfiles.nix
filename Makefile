# Documentation (won't show in output)
###############################################################################
# Makefile for NixOS/nix-darwin system management
#
# Targets:
# - all:      deploy changes and clean old generations
# - deploy:   auto-detects OS and deploys appropriate configuration
# - test:     test configuration without switching to it
# - update:   updates all dependencies and deploys
# - install:  first-time setup for macOS systems
# - lint:     format and lint nix files
# - clean:    remove old system generations
# - repair:   fix git hooks and verify nix store
#
# Usage:
# 1. First time setup:    make install
# 2. Regular deploys:     make deploy
# 3. Update everything:   make update
# 4. Test changes:        make test
#
# Features:
# - Automatic OS detection
# - Sudo credential caching
# - Colored status output
# - Auto-commit of changes
# - Error logging
###############################################################################

MAKEFLAGS += --no-print-directory
NIX_FLAGS = --extra-experimental-features 'nix-command flakes' --accept-flake-config
include format.mk
.PHONY: all deploy deploy-darwin deploy-nixos test test-darwin test-nixos update install lint clean repair

define get_commit_message
OS_TYPE=$$(if [ "$$(uname)" = "Darwin" ]; then echo "darwin"; else echo "nixos"; fi); \
CHANGES=$$(git diff --cached --name-only | sed ':a;N;$$!ba;s/\n/\\n/g'); \
SUMMARY=$$(git diff --cached --compact-summary | sed ':a;N;$$!ba;s/\n/\\n/g'); \
printf "[%s] Gen: %s\n\nChanged files:\n%b\n\nSummary:\n%b" "$${OS_TYPE}" "$(1)" "$${CHANGES}" "$${SUMMARY}"
endef


all: deploy clean

deploy:
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) deploy-darwin; \
	else \
		$(MAKE) deploy-nixos; \
	fi

test:
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) test-darwin; \
	else \
		$(MAKE) test-nixos; \
	fi

deploy-darwin:
	@echo "${HEADER}Starting Darwin Deployment${RESET}"
	@echo "${INFO} Caching sudo authentication..."
	@sudo -v
	@{ \
		while true; do \
			sudo -n true; \
			sleep 60; \
			kill -0 "$$" || exit; \
		done 2>/dev/null & \
		git add . && \
		echo "${INFO} Running lints and checks..." && \
		$(MAKE) -s lint || (echo "${ERROR} Linting failed" && exit 1) && \
		echo "${INFO} Checking for changes..." && \
		git --no-pager diff --no-prefix --minimal --unified=0 . && \
		echo "${INFO} Rebuilding Darwin system..." && \
		(darwin-rebuild switch --flake .#darwin 2>darwin-switch.log && \
			echo "${SUCCESS} System rebuilt successfully") || \
			(echo "${ERROR} Build failed with errors:" && \
			cat darwin-switch.log | grep --color error && false) && \
		gen=$$(darwin-rebuild switch --flake .#darwin --list-generations | grep current| sed -E 's/([0-9]*)   ([0-9]*-[0-9]*-[0-9]*) ([0-9]*:[0-9]*)(:[0-9]*)   \(current\)/\1 - \2 at \3/') && \
		export NIXOS_GENERATION_COMMIT=1 && \
		git commit -m "$$($(call get_commit_message,$$gen))" > /dev/null && \
		echo "${SUCCESS} Changes committed for generation: $$gen" && \
		echo "${DONE}Darwin deployment complete!${RESET}"; \
	}

test-darwin:
	@echo "${HEADER}Testing Darwin Configuration${RESET}"
	@echo "${INFO} Caching sudo authentication..."
	@sudo -v
	@{ \
		while true; do \
			sudo -n true; \
			sleep 60; \
			kill -0 "$$" || exit; \
		done 2>/dev/null & \
		echo "${INFO} Running lints and checks..." && \
		$(MAKE) -s lint || (echo "${ERROR} Linting failed" && exit 1) && \
		echo "${INFO} Testing Darwin configuration..." && \
		(darwin-rebuild check --flake .#darwin 2>darwin-test.log && \
			echo "${SUCCESS} Configuration test successful") || \
			(echo "${ERROR} Test failed with errors:" && \
			cat darwin-test.log | grep --color error && false) && \
		echo "${DONE}Darwin test complete!${RESET}"; \
	}

deploy-nixos:
	@echo "${HEADER}Starting NixOS Deployment${RESET}"
	@echo "${INFO} Caching sudo authentication..."
	@sudo -v
	@{ \
		while true; do \
			sudo -n true; \
			sleep 60; \
			kill -0 "$$" || exit; \
		done 2>/dev/null & \
		trap 'kill %1' EXIT; \
		git add . && \
		echo "${INFO} Running lints and checks..." && \
		$(MAKE) -s lint || (echo "${ERROR} Linting failed" && exit 1) && \
		echo "${INFO} Checking for changes..." && \
		git --no-pager diff --no-prefix --minimal --unified=0 . && \
		echo "${INFO} Rebuilding NixOS system..." && \
		if sudo nixos-rebuild switch --flake .#nixos 2>nixos-switch.log; then \
			echo "${SUCCESS} System rebuilt successfully" && \
			gen="$$(nixos-rebuild list-generations | grep current| sed -E 's/([0-9]*) (current)  ([0-9]*-[0-9]*-[0-9]*) ([0-9]*:[0-9]*)(:[0-9]*)(.*)/\1 · \3 at \4/')" && \
			export NIXOS_GENERATION_COMMIT=1 && \
			git commit -m "$$($(call get_commit_message,$$gen))" > /dev/null && \
			echo "${SUCCESS} Changes committed for generation: $$gen" && \
			exit 0; \
		else \
			echo "${ERROR} Build failed with errors:" && \
			cat nixos-switch.log | grep --color error && \
			exit 1; \
		fi; \
	}

test-nixos:
	@echo "${HEADER}Testing NixOS Configuration${RESET}"
	@echo "${INFO} Caching sudo authentication..."
	@sudo -v
	@{ \
		while true; do \
			sudo -n true; \
			sleep 60; \
			kill -0 "$$" || exit; \
		done 2>/dev/null & \
		trap 'kill %1' EXIT; \
		echo "${INFO} Running lints and checks..." && \
		$(MAKE) -s lint || (echo "${ERROR} Linting failed" && exit 1) && \
		echo "${INFO} Testing NixOS configuration..." && \
		if sudo nixos-rebuild test --flake .#nixos 2>nixos-test.log; then \
			echo "${SUCCESS} Configuration test successful" && \
			exit 0; \
		else \
			echo "${ERROR} Test failed with errors:" && \
			cat nixos-test.log | grep --color error && \
			exit 1; \
		fi; \
	}

update:
	git add .
	@echo "${INFO} Updating channels..."
	@nix-channel --update
	@echo "${INFO} Updating flakes..."
	@nix $(NIX_FLAGS) flake update
	@echo "${SUCCESS} Updates complete, starting deployment"
	@$(MAKE) deploy

install:
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "${ERROR} Install is only supported on MacOS"; \
		exit 1; \
	fi
	@echo "${HEADER}Starting MacOS Setup${RESET}"
	@if ! command -v nix >/dev/null 2>&1; then \
		echo "${INFO} Installing Nix..." && \
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install && \
		echo "${SUCCESS} Nix installed successfully!" && \
		echo "${WARN} Please restart your terminal and run 'make install' again." && \
		exit 0; \
	fi
	@echo "${INFO} Installing Homebrew..."
	@command -v brew >/dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	@echo "${INFO} Setting up channels..."
	@nix-channel --remove darwin || true
	@nix-channel --remove home-manager || true
	@nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
	@nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
	@nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	@nix-channel --update
	@if ! command -v darwin-rebuild > /dev/null 2>&1; then \
		echo "${INFO} Installing nix-darwin..." && \
		nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer && \
		./result/bin/darwin-installer; \
	fi
	@echo "${INFO} Setting up git hooks..."
	@mkdir -p .git/hooks
	@cp $(PWD)/.github/hooks/pre-commit .git/hooks/
	@chmod +x .git/hooks/pre-commit
	@echo "${INFO} Installing home-manager..."
	@nix-shell '<home-manager>' -A install
	@$(MAKE) init-darwin
	@echo "${SUCCESS} Installation complete!"
	@echo "${WARN} Please restart your shell and run 'make deploy'\n"

lint:
	@nix $(NIX_FLAGS) fmt .
	@nix run $(NIX_FLAGS) nixpkgs#statix -- check .
	@nix run $(NIX_FLAGS) nixpkgs#deadnix -- -eq .

clean:
	@echo "${INFO} Cleaning up old generations..."
	@sudo nix-collect-garbage -d
	@echo "${SUCCESS} Cleanup complete"

repair:
	@echo "${INFO} Configuring git hooks..."
	@git config core.hooksPath ./.github/hooks
	@echo "${INFO} Verifying and repairing Nix store..."
	@sudo nix-store --verify --check-contents --repair
	@echo "${SUCCESS} Repair complete"
