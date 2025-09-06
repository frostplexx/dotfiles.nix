# Neovim live editing commands
# These commands help with live editing neovim config by symlinking to a test instance

set shell := ["bash", "-c"]
set positional-arguments

NVIM_CONFIG_SOURCE := DOTFILES_FOLDER + "/home/neovim/nvim"
NVIM_CONFIG_TARGET := env_var('HOME') + "/.config/nvim-new"

# Start live editing by symlinking nvim config to nvim-new
[group(' nvim')]
[doc('Tools for editing the neovim config without having to redeploy nix')]
edit-nvim action="help" *args="":
    #!/usr/bin/env bash
    set -euo pipefail

    case "{{action}}" in
        "start")
            echo "🔗 Creating symlink for live neovim editing..."
            if [[ -L "{{NVIM_CONFIG_TARGET}}" ]] || [[ -e "{{NVIM_CONFIG_TARGET}}" ]]; then
                echo "❌ {{NVIM_CONFIG_TARGET}} already exists. Run 'jinx edit-nvim stop' first."
                exit 1
            fi
            if [[ ! -d "{{NVIM_CONFIG_SOURCE}}" ]]; then
                echo "❌ Source directory not found: {{NVIM_CONFIG_SOURCE}}"
                exit 1
            fi
            mkdir -p "$(dirname {{NVIM_CONFIG_TARGET}})"
            ln -s "{{NVIM_CONFIG_SOURCE}}" "{{NVIM_CONFIG_TARGET}}"
            echo "✅ Symlink created: {{NVIM_CONFIG_SOURCE}} -> {{NVIM_CONFIG_TARGET}}"
            echo "💡 Use 'jinx edit-nvim open' to open neovim with the test config"
            ;;
        "stop")
            echo "🗑️  Removing symlink for live neovim editing..."
            if [[ ! -L "{{NVIM_CONFIG_TARGET}}" ]]; then
                echo "❌ No symlink found at {{NVIM_CONFIG_TARGET}}"
                exit 1
            fi
            rm "{{NVIM_CONFIG_TARGET}}"
            echo "✅ Symlink removed: {{NVIM_CONFIG_TARGET}}"
            ;;
        "restart")
            echo "🔄 Restarting neovim live editing..."
            # Stop if exists
            if [[ -L "{{NVIM_CONFIG_TARGET}}" ]]; then
                rm "{{NVIM_CONFIG_TARGET}}"
                echo "✅ Symlink removed: {{NVIM_CONFIG_TARGET}}"
            fi
            # Start
            if [[ ! -d "{{NVIM_CONFIG_SOURCE}}" ]]; then
                echo "❌ Source directory not found: {{NVIM_CONFIG_SOURCE}}"
                exit 1
            fi
            mkdir -p "$(dirname {{NVIM_CONFIG_TARGET}})"
            ln -s "{{NVIM_CONFIG_SOURCE}}" "{{NVIM_CONFIG_TARGET}}"
            echo "✅ Symlink created: {{NVIM_CONFIG_SOURCE}} -> {{NVIM_CONFIG_TARGET}}"
            ;;
        "open")
            echo "🚀 Opening neovim with test config..."
            if [[ ! -L "{{NVIM_CONFIG_TARGET}}" ]]; then
                echo "❌ No symlink found at {{NVIM_CONFIG_TARGET}}. Run 'jinx edit-nvim start' first."
                exit 1
            fi
            NVIM_APPNAME=nvim-new nvim
            ;;
        "status")
            echo "📋 Neovim live editing status:"
            echo "Source: {{NVIM_CONFIG_SOURCE}}"
            echo "Target: {{NVIM_CONFIG_TARGET}}"
            echo ""
            if [[ -L "{{NVIM_CONFIG_TARGET}}" ]]; then
                echo "✅ Symlink active: {{NVIM_CONFIG_TARGET}} -> $(readlink {{NVIM_CONFIG_TARGET}})"
                if [[ ! -d "{{NVIM_CONFIG_SOURCE}}" ]]; then
                    echo "⚠️  Warning: Source directory does not exist!"
                fi
            elif [[ -e "{{NVIM_CONFIG_TARGET}}" ]]; then
                echo "⚠️  {{NVIM_CONFIG_TARGET}} exists but is not a symlink"
                echo "   Type: $(file {{NVIM_CONFIG_TARGET}})"
            else
                echo "❌ No symlink found at {{NVIM_CONFIG_TARGET}}"
            fi
            ;;
        "clean")
            echo "🧹 Cleaning up neovim test config..."
            if [[ -e "{{NVIM_CONFIG_TARGET}}" ]]; then
                if [[ -L "{{NVIM_CONFIG_TARGET}}" ]]; then
                    rm "{{NVIM_CONFIG_TARGET}}"
                    echo "✅ Removed symlink: {{NVIM_CONFIG_TARGET}}"
                else
                    echo "⚠️  {{NVIM_CONFIG_TARGET}} exists but is not a symlink"
                    echo "   Manual removal required for safety"
                    exit 1
                fi
            else
                echo "✅ No cleanup needed - {{NVIM_CONFIG_TARGET}} doesn't exist"
            fi
            ;;
        "check")
            echo "🔍 Checking prerequisites..."

            # Check if source exists
            if [[ ! -d "{{NVIM_CONFIG_SOURCE}}" ]]; then
                echo "❌ Source directory not found: {{NVIM_CONFIG_SOURCE}}"
                exit 1
            else
                echo "✅ Source directory exists: {{NVIM_CONFIG_SOURCE}}"
            fi

            # Check if nvim is available
            if ! command -v nvim >/dev/null 2>&1; then
                echo "❌ Neovim not found in PATH"
                exit 1
            else
                echo "✅ Neovim found: $(which nvim)"
                echo "   Version: $(nvim --version | head -n1)"
            fi

            # Check target directory parent
            target_parent="$(dirname {{NVIM_CONFIG_TARGET}})"
            if [[ ! -d "$target_parent" ]]; then
                echo "⚠️  Target parent directory doesn't exist: $target_parent"
                echo "   Will be created automatically"
            else
                echo "✅ Target parent directory exists: $target_parent"
            fi

            echo ""
            echo "✅ All prerequisites satisfied"
            ;;
        "help"|"")
            echo "🔧 Neovim live editing commands:"
            echo ""
            echo "Usage: jinx edit-nvim <action> [args...]"
            echo ""
            echo "Actions:"
            echo "  start    - Create symlink for live editing"
            echo "  stop     - Remove symlink"
            echo "  restart  - Stop and start again"
            echo "  open     - Open neovim with test config (accepts nvim args)"
            echo "  status   - Show current status"
            echo "  clean    - Force cleanup of target"
            echo "  check    - Check prerequisites"
            echo "  help     - Show this help message"
            echo ""
            echo "Examples:"
            echo "  jinx edit-nvim start"
            echo "  jinx edit-nvim open file.lua"
            echo "  jinx edit-nvim status"
            ;;
        *)
            echo "❌ Unknown action: {{action}}"
            echo "💡 Use 'jinx edit-nvim help' to see available actions"
            exit 1
            ;;
    esac
