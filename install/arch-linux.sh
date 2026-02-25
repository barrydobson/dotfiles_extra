#!/bin/bash

# =============================================================================
# Arch Linux Bootstrap
# =============================================================================
# Installs minimal system packages, yay (AUR helper), and mise.
# Tool installation happens via mise after stowing.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./common.sh
source "${SCRIPT_DIR}/common.sh"

check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script is for Arch Linux only."
        exit 1
    fi
}

install_system_packages() {
    print_status "Installing system packages..."

    local packages=(
        curl
        fzf
        git
        gnupg
        gpg
        gpg-agent
        stow
        zsh
        base-devel
    )

    if check_sudo_access; then
        sudo pacman -Syu --noconfirm
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        print_success "System packages installed"
    else
        print_warning "Cannot install packages automatically - requires sudo"
        print_warning "Run: sudo pacman -S --needed --noconfirm ${packages[*]}"
    fi
}

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        print_status "yay is already installed"
        return
    fi

    print_status "Installing yay (AUR helper)..."

    if check_sudo_access; then
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay && makepkg -si --noconfirm
        cd ~ && rm -rf /tmp/yay
        print_success "yay installed"
    else
        print_warning "Cannot install yay automatically - requires sudo"
        print_warning "Clone https://aur.archlinux.org/yay.git and run: makepkg -si"
    fi
}

main() {
    check_arch_linux
    install_system_packages
    install_yay
    install_mise
    post_install_setup
}

main "$@"
