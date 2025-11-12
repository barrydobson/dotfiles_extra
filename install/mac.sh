#!/bin/bash

# =============================================================================
# macOS Dotfiles Dependencies Installation Script
# =============================================================================
# This script installs all the required dependencies for the dotfiles to work
# properly on macOS. It handles Homebrew installations and configurations.

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
}

# Check if Homebrew is installed
check_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        print_status "Homebrew is available"
        return 0
    else
        print_warning "Homebrew is not installed"
        return 1
    fi
}

# Install Homebrew if not present
install_homebrew() {
    print_status "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        print_success "Homebrew installed (Apple Silicon)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        print_success "Homebrew installed (Intel)"
    else
        print_error "Homebrew installation failed"
        exit 1
    fi
}

# Update Homebrew
update_homebrew() {
    print_status "Updating Homebrew..."
    brew update
    brew upgrade
    print_success "Homebrew updated"
}

# Install packages from Homebrew
install_homebrew_packages() {
    print_status "Installing packages from Homebrew..."
    local brewfile_path=""

    if [[ -f "${HOME}/.Brewfile" ]]; then
        brewfile_path="${HOME}/.Brewfile"
    elif [[ -f "./packages/homebrew/dot-Brewfile" ]]; then
        brewfile_path="./packages/homebrew/dot-Brewfile"
    else
        print_warning "No Brewfile found, skipping package installation"
        return
    fi
    brew bundle check --file "${brewfile_path}" || brew bundle install --file "${brewfile_path}"

    print_success "Homebrew packages installation completed"
}

# Install and configure Catppuccin theme for bat
install_catppuccin_bat() {
    print_status "Installing Catppuccin themes for bat..."

    # Check if bat is installed
    if command -v bat >/dev/null 2>&1; then
        # Create bat themes directory
        local bat_themes_dir
        bat_themes_dir="$(bat --config-dir)/themes"
        mkdir -p "${bat_themes_dir}"

        # Define all Catppuccin themes
        local themes=(
            "Catppuccin%20Latte.tmTheme:Catppuccin-Latte.tmTheme"
            "Catppuccin%20Frappe.tmTheme:Catppuccin-Frappe.tmTheme"
            "Catppuccin%20Macchiato.tmTheme:Catppuccin-Macchiato.tmTheme"
            "Catppuccin%20Mocha.tmTheme:Catppuccin-Mocha.tmTheme"
        )

        local themes_installed=false

        # Download each theme if not already present
        for theme_info in "${themes[@]}"; do
            local url_name="${theme_info%%:*}"
            local file_name="${theme_info##*:}"
            local theme_file="${bat_themes_dir}/${file_name}"

            if [[ ! -f "${theme_file}" ]]; then
                print_status "Downloading ${file_name} theme for bat..."
                curl -L -o "${theme_file}" "https://github.com/catppuccin/bat/raw/main/themes/${url_name}"
                themes_installed=true
            fi
        done

        # Rebuild bat cache if any themes were installed
        if [[ "${themes_installed}" == true ]]; then
            print_status "Rebuilding bat theme cache..."
            bat cache --build
            print_success "Catppuccin themes for bat installed"
        else
            print_status "Catppuccin themes for bat already installed"
        fi
    else
        print_warning "bat not installed, skipping Catppuccin themes"
    fi
}

# Install Zinit (Zsh plugin manager)
install_zinit() {
    print_status "Installing Zinit (Zsh plugin manager)..."

    local zinit_home="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

    if [[ ! -d "${zinit_home}" ]]; then
        mkdir -p "$(dirname "${zinit_home}")"
        git clone https://github.com/zdharma-continuum/zinit.git "${zinit_home}"
        print_success "Zinit installed"
    else
        print_status "Zinit is already installed"
    fi
}

# Install FZF from git (for latest version)
install_fzf() {
    print_status "Installing FZF from git..."

    if [[ ! -d "${HOME}/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
        print_success "FZF installed from git"
    else
        print_status "FZF is already installed"
    fi
}

# Install TPM (Tmux Plugin Manager)
install_tpm() {
    print_status "Installing TPM (Tmux Plugin Manager)..."

    local tpm_dir="${HOME}/.tmux/plugins/tpm"

    if [[ ! -d "${tpm_dir}" ]]; then
        mkdir -p "${HOME}/.tmux/plugins"
        git clone https://github.com/tmux-plugins/tpm "${tpm_dir}"
        print_success "TPM installed"
    else
        print_status "TPM is already installed"
    fi
}

setup_1password() {
    if command -v op >/dev/null 2>&1; then
        print_status "1Password CLI is available"
        return 0
    else
        print_warning "1Password CLI is not installed"
        return 1
    fi
    mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
}

# Post-installation setup
post_install_setup() {
    print_status "Performing post-installation setup..."

    # Change default shell to zsh if not already set (though macOS uses zsh by default now)
    if [[ "${SHELL}" != */zsh ]]; then
        print_status "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        print_success "Default shell changed to zsh (restart required)"
    else
        print_status "Default shell is already zsh"
    fi

    # Create necessary directories
    mkdir -p "${HOME}/.local/bin"
    mkdir -p "${HOME}/.local/share"
    mkdir -p "${HOME}/.config"

    # Ensure /opt/homebrew/bin is in PATH for Apple Silicon Macs
    if [[ -d "/opt/homebrew/bin" ]] && [[ ":${PATH}:" != *":/opt/homebrew/bin:"* ]]; then
        print_status "Adding Homebrew to PATH for current session"
        export PATH="/opt/homebrew/bin:${PATH}"
    fi

    print_success "Post-installation setup completed"
}

# Main execution
main() {
    print_status "Starting macOS dotfiles dependencies installation..."

    # Check prerequisites
    check_macos

    # Install Homebrew if not present
    if ! check_homebrew; then
        install_homebrew
    fi

    # Update Homebrew
    update_homebrew

    # Install packages
    install_homebrew_packages

    # Configure tools
    install_catppuccin_bat

    # Install additional tools
    install_zinit
    install_fzf
    install_tpm

    setup_1password

    # Post-installation setup
    post_install_setup

    print_success "All dependencies installed successfully!"
    print_status "You can now run 'make stow' to set up your dotfiles."
    print_warning "Note: You may need to restart your terminal for all changes to take effect."
    print_warning "GUI applications have been installed to ${HOME}/Applications"
}

# Run main function
main "$@"
