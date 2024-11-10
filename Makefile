NIX_FLAGS = --extra-experimental-features 'nix-command flakes'

.PHONY: all deploy update lint clean repair install

all: deploy clean

# Full system deployment
deploy:
	@if [ "$$(uname)" = "Darwin" ]; then \
		$(MAKE) deploy-darwin; \
	else \
		$(MAKE) deploy-nixos; \
	fi

# Deploy only nix-darwin changes
deploy-darwin:
	darwin-rebuild switch --flake .#darwin

deploy-nixos:
	sudo nixos-rebuild switch --flake .#nixos

# Update nix-darwin and show changelog
update:
	nix-channel --update
	nix --extra-experimental-features nix-command --extra-experimental-features flakes flake update
	$(MAKE) deploy

# Setup homebrew, nix, nix-darwin and home-manager
install:
	@if [ "$$(uname)" != "Darwin" ]; then \
		echo "Install is only supported on MacOS"; \
		exit 1; \
	fi
	# Install Nix
	@if ! command -v nix >/dev/null 2>&1; then \
		curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install; \
		echo ""; \
		echo "==> Nix installed successfully!"; \
		echo "==> Please RESTART YOUR TERMINAL and run 'make install' again to continue the installation process."; \
		echo ""; \
		exit 0; \
	fi
	# Install Homebrew if not installed
	@command -v brew >/dev/null 2>&1 || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	# Setup channels
	nix-channel --remove darwin || true
	nix-channel --remove home-manager || true
	nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
	nix-channel --add https://github.com/LnL7/nix-darwin/archive/master.tar.gz darwin
	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update
	# Install nix-darwin
	@if ! command -v darwin-rebuild > /dev/null 2>&1; then \
		echo "Installing nix-darwin..." && \
		nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer && \
		./result/bin/darwin-installer; \
	fi
  # Set up pre commit hooks
	git config core.hooksPath ./.github/hooks
	# Install home-manager
	nix-shell '<home-manager>' -A install
	# Initialize nix-darwin
	$(MAKE) init-darwin
	@echo ""
	@echo "==> Installation complete!"
	@echo "==> Please restart your shell and run 'make deploy'"
	@echo ""

# Check flake configuration
lint:
  # Format
	nix --extra-experimental-features nix-command --extra-experimental-features flakes fmt
  # Linting
	nix run --extra-experimental-features 'nix-command flakes' nixpkgs#statix -- check .
  # Fidn dead code
	nix run --extra-experimental-features 'nix-command flakes' nixpkgs#deadnix -- -eq .

# Clean up old generations and store
clean:
	sudo nix-collect-garbage -d

repair:
	git config core.hooksPath ./.github/hooks
	sudo nix-store --verify --check-contents --repair
