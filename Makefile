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

include ./utils/format.mk
.PHONY: all deploy upgrade install lint clean repair

all: deploy

deploy: lint
	@bash ./utils/system-deploy.sh deploy

upgrade: lint
	@bash ./utils/system-deploy.sh update

install:
	@bash ./utils/system-install.sh

clean:
	@nix run github:viperml/nh -- clean all

repair:
	@sudo nix-store --verify --check-contents --repair

lint:
	@bash ./utils/lint.sh
