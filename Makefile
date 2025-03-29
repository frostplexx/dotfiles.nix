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

NIX_FLAGS = --extra-experimental-features 'nix-command flakes' --accept-flake-config 

HOSTNAME = hostname |sed -E 's/([a-z]*-)([a-z]*-)([a-z]*)/\3/';

include ./utils/format.mk
.PHONY: all deploy upgrade install lint clean repair select

all: deploy clean

select:
	@bash ./utils/system-deploy.sh

deploy:
	@bash ./utils/system-deploy.sh

upgrade:
	@bash ./utils/system-upgrade.sh

install:
	@bash ./utils/system-install.sh

clean:
	@bash ./utils/system-clean.sh

repair:
	@bash ./utils/system-repair.sh

lint:
	@bash ./utils/lint.sh
