#!/bin/bash

# =============================================================================
# macOS Bootstrap
# =============================================================================
# Installs Homebrew. Package installation happens via Brewfile after stowing.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is for macOS only."
        exit 1
    fi
}

install_homebrew() {
    print_status "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

install_system_packages() {
    print_status "Installing system packages..."

    local packages=(
        zsh
        git
        stow
    )

    brew install "${packages[@]}"
    print_success "System packages installed"
}

main() {
    check_macos

    if command -v brew >/dev/null 2>&1; then
        print_status "Homebrew is already installed"
        brew update && brew upgrade
    else
        install_homebrew
    fi
    install_system_packages
    post_install_setup

}

main "$@"
