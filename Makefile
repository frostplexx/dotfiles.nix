###############################################################################
# Makefile for NixOS/nix-darwin system management
#
# Targets:
# - all:      deploy changes and clean old generations
# - deploy:   auto-detects OS and deploys appropriate configuration
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
#
# Features:
# - Automatic OS detection
# - Sudo credential caching
# - Colored status output
# - Auto-commit of changes
# - Error logging
###############################################################################

MAKEFLAGS += --no-print-directory

NIX_FLAGS = --extra-experimental-features 'nix-command flakes' --accept-flake-config --show-trace

HOSTNAME = hostname |sed -E 's/([a-z]*-)([a-z]*-)([a-z]*)/\3/';

include format.mk
.PHONY: all update lint clean repair install

all: select 

select:
	@CONFIGS=$$(awk '/= \{/{name=$$1} /system =/{if(name) print name}' hosts/default.nix | sed 's/=//' | tr -d ' ') && \
	if echo "$$CONFIGS" | grep -q "$$($(HOSTNAME))"; then \
		$(MAKE) deploy CONFIG=$$($(HOSTNAME)); \
	else \
		echo "${INFO} Hostname not found in configs. Select a configuration:" && \
		SELECTED_CONFIG=$$(echo "$$CONFIGS" | nix-shell -p fzf --run "fzf") && \
		if [ -n "$$SELECTED_CONFIG" ]; then \
			$(MAKE) deploy CONFIG=$$SELECTED_CONFIG; \
		else \
			echo "${ERROR} No configuration selected"; \
			exit 1; \
		fi \
	fi

deploy:
	@git --no-pager diff --no-prefix --minimal --unified=0 . && \
	echo "${INFO} Running lints and checks..." && \
	$(MAKE) -s lint || (echo "${ERROR} Linting failed" && exit 1) && \
	git add . && \
	echo "${INFO} Deploying $(CONFIG) configuration..." && \
	rm -rf ~/.gtkrc-2.0 && \
	NIX_CMD=$$(if [ "$$(uname)" = "Darwin" ]; then echo "darwin-rebuild"; else echo "sudo nixos-rebuild"; fi) && \
	if $$NIX_CMD switch --flake .#$(CONFIG) 2>$(CONFIG)-switch.log; then \
		echo "${SUCCESS} $(CONFIG) configuration deployed successfully" && \
		echo "${INFO} Please enter a commit message:" && \
		read -p "→ " commit_msg && \
		git commit -m "$$commit_msg" > /dev/null; \
	else \
		echo "${ERROR} $(CONFIG) configuration deployment failed" && \
		cat $(CONFIG)-switch.log | grep --color error && \
		exit 1; \
	fi

update:
	git add .
	@echo "${INFO} Updating flakes..."
	@nix $(NIX_FLAGS) flake update
	@echo "${SUCCESS} Updates complete, starting deployment"
	@$(MAKE) select


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
	@if ! command -v darwin-rebuild > /dev/null 2>&1; then \
		echo "${INFO} Installing nix-darwin..." && \
		nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer && \
		./result/bin/darwin-installer; \
	fi
	@echo "${INFO} Installing home-manager..."
	@nix-shell '<home-manager>' -A install
	@$(MAKE) init-darwin
	@echo "${SUCCESS} Installation complete!"
	@echo "${WARN} Please restart your shell and run 'make deploy'\n"

clean:
	@echo "${INFO} Cleaning up old generations..."
	@sudo nix-collect-garbage -d
	@echo "${SUCCESS} Cleanup complete"

repair:
	@echo "${INFO} Configuring git hooks..."
	@echo "${INFO} Verifying and repairing Nix store..."
	@sudo nix-store --verify --check-contents --repair
	@echo "${SUCCESS} Repair complete"

lint:
	@nix $(NIX_FLAGS) fmt . 2> /dev/null
	@nix run $(NIX_FLAGS) nixpkgs#statix -- check .
	@nix run $(NIX_FLAGS) nixpkgs#deadnix -- -eq .
