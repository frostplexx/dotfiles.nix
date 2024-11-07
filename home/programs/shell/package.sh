#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check operating system
OS="$(uname)"
if [ "$OS" = "Darwin" ]; then
    APPS_NIX="${SCRIPT_DIR}/hosts/darwin/apps.nix"
elif [ "$OS" = "Linux" ]; then
    APPS_NIX="${SCRIPT_DIR}/hosts/nixos/apps.nix"
else
    echo "Unsupported operating system: $OS"
    exit 1
fi

# Get the dotfiles directory directly
DOTFILES_DIR="${HOME}/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Error: Could not find dotfiles directory at ${DOTFILES_DIR}"
    exit 1
fi

# Check operating system and set correct path
OS="$(uname)"
if [ "$OS" = "Darwin" ]; then
    APPS_NIX="${DOTFILES_DIR}/hosts/darwin/apps.nix"
elif [ "$OS" = "Linux" ]; then
    APPS_NIX="${DOTFILES_DIR}/hosts/nixos/apps.nix"
else
    echo "Unsupported operating system: $OS"
    exit 1
fi

# Verify the apps.nix file exists
if [ ! -f "$APPS_NIX" ]; then
    echo "Error: Could not find apps.nix at ${APPS_NIX}"
    exit 1
fi

# Check for required tools
if ! command -v fzf &>/dev/null; then
    echo "fzf could not be found. Please install it first."
    exit 1
fi

# Function to search for packages
search_packages() {
    QUERY="$1"

    # Search nixpkgs
    NIX_RESULTS=$(nix --extra-experimental-features nix-command --extra-experimental-features flakes search nixpkgs "$QUERY" --json | jq -r 'to_entries[] | "\(.value.pname) (\(.value.version)) (nixpkgs)"')

    if [ "$OS" = "Darwin" ]; then
        # Search Homebrew formulae
        BREW_FORMULAE=$(brew search --formula "$QUERY" | awk '{print $0" (homebrew formula)"}')
        # Search Homebrew casks
        BREW_CASKS=$(brew search --cask "$QUERY" | awk '{print $0" (homebrew cask)"}')
        # Combine results
        PACKAGE_LIST=$(printf "%s\n%s\n%s" "$NIX_RESULTS" "$BREW_FORMULAE" "$BREW_CASKS" | grep -v '^$')
    else
        PACKAGE_LIST=$(printf "%s" "$NIX_RESULTS" | grep -v '^$')
    fi

    # Display in fzf
    SELECTED=$(echo "$PACKAGE_LIST" | fzf --prompt="Select a package to install: ")
    if [ -z "$SELECTED" ]; then
        echo "No package selected."
        exit 1
    fi

    PACKAGE_NAME=$(echo "$SELECTED" | awk '{print $1}')
    PACKAGE_SOURCE=$(echo "$SELECTED" | awk -F'(' '{print $2}' | tr -d ')')

    install_package "$PACKAGE_NAME" "$PACKAGE_SOURCE"
}


# Function to install package
install_package() {
    PACKAGE_NAME="$1"
    PACKAGE_SOURCE="$2"

    # Append the package to the correct array
    if [ "$PACKAGE_SOURCE" = "nixpkgs" ]; then
        sed -i.bak "/^ *environment\.systemPackages = with pkgs; \[/a\\
            $PACKAGE_NAME
        " "$APPS_NIX"
    elif [ "$PACKAGE_SOURCE" = "homebrew formula" ]; then
        sed -i.bak "/^ *brews = \[/a\\
            \"$PACKAGE_NAME\"
        " "$APPS_NIX"
    elif [ "$PACKAGE_SOURCE" = "homebrew cask" ]; then
        sed -i.bak "/^ *casks = \[/a\\
            \"$PACKAGE_NAME\"
        " "$APPS_NIX"
    else
        echo "Invalid package source."
        exit 1
    fi

    # Create a commit with the added package
    (cd "$DOTFILES_DIR" && git add "$APPS_NIX" && git commit -m "feat: add $PACKAGE_NAME")

    # Run make inside dotfiles directory
    (cd "$DOTFILES_DIR" && make)
}

# Function to list installed packages
list_packages() {
    echo -e "\033[94;1m󱄅 Installed Nixpkgs Packages:\033[0m"
    # Extract Nix packages
    nix_packages=$(sed -n '/environment\.systemPackages = with pkgs; \[/,/];/p' "$APPS_NIX" | \
                   grep -v 'environment\.systemPackages' | \
                   grep -v '^\s*$' | \
                   grep -v '];' | \
                   sed 's/#.*$//' | \
                   sed 's/^[ \t]*//' | \
                   sed 's/,*$//')

    # Format the Nix packages output with tabs between packages
    echo "$nix_packages" | xargs -n10 | sed -E 's/ +/\t/g' | column -t -s $'\t'
    echo ""

    if [ "$OS" = "Darwin" ]; then
        # Homebrew Formulas
        echo -e "\033[94;1m Installed Homebrew formulas:\033[0m"
        brew_formulas=$(sed -n '/brews = \[/,/];/p' "$APPS_NIX" | \
                        grep -v 'brews = \[' | \
                        grep -v '^\s*$' | \
                        grep -v '];' | \
                        sed 's/#.*$//' | \
                        sed 's/^[ \t]*//' | \
                        sed 's/"//g' | \
                        sed 's/,*$//')

        echo "$brew_formulas" | xargs -n10 | sed -E 's/ +/\t/g' | column -t -s $'\t'
        echo ""

        # Homebrew Casks
        echo -e "\033[94;1m Installed Homebrew casks:\033[0m"
        brew_casks=$(sed -n '/casks = \[/,/];/p' "$APPS_NIX" | \
                     grep -v 'casks = \[' | \
                     grep -v '^\s*$' | \
                     grep -v '];' | \
                     sed 's/#.*$//' | \
                     sed 's/^[ \t]*//' | \
                     sed 's/"//g' | \
                     sed 's/,*$//')

        echo "$brew_casks" | xargs -n10 | sed -E 's/ +/\t/g' | column -t -s $'\t'
        echo ""
    fi
}

# Function to uninstall package
uninstall_package() {
    PACKAGE_NAME="$1"

    if [ -z "$PACKAGE_NAME" ]; then
        echo "Usage: addpkg uninstall <package-name>"
        exit 1
    fi

    if grep -q "$PACKAGE_NAME" "$APPS_NIX"; then
        # Remove the package from the file
        sed -i.bak "/$PACKAGE_NAME/d" "$APPS_NIX"

        # Create a commit with the removal
        git add "$APPS_NIX"
        git commit -m "feat: remove $PACKAGE_NAME"

        # Run make inside ~/dotfiles to update the system
        cd ~/dotfiles && make
    else
        echo "Package '$PACKAGE_NAME' not found in the configuration."
        exit 1
    fi
}

# Function to update packages
update_packages() {
    cd ~/dotfiles && make update
}

# Main script logic
case "$1" in
    search)
        shift
        if [ -z "$1" ]; then
            echo "Usage: addpkg search <package-name>"
            exit 1
        fi
        search_packages "$1"
        ;;
    install)
        shift
        if [ -z "$1" ]; then
            echo "Usage: addpkg install <package-name>"
            exit 1
        fi
        PACKAGE_NAME="$1"

        if [ "$OS" = "Darwin" ]; then
            # Let user choose between Homebrew or Nixpkgs
            PACKAGE_SOURCE=$(printf "homebrew\nnixpkgs" | fzf --prompt="Select package source: ")
            if [ -z "$PACKAGE_SOURCE" ]; then
                echo "No selection made."
                exit 1
            fi

            if [ "$PACKAGE_SOURCE" = "homebrew" ]; then
                # Ask user to choose between formula and cask
                HOMEBREW_TYPE=$(printf "formula\ncask" | fzf --prompt="Select Homebrew type: ")
                if [ -z "$HOMEBREW_TYPE" ]; then
                    echo "No selection made."
                    exit 1
                fi
                PACKAGE_SOURCE="homebrew $HOMEBREW_TYPE"
            fi
        else
            PACKAGE_SOURCE="nixpkgs"
        fi

        install_package "$PACKAGE_NAME" "$PACKAGE_SOURCE"
        ;;
    list)
        list_packages
        ;;
    uninstall)
        shift
        uninstall_package "$1"
        ;;
    update)
        update_packages
        ;;
    *)
        echo "Usage: addpkg [search|install|list|uninstall|update] <package-name>"
        exit 1
        ;;
esac