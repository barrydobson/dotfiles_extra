#!/bin/bash

# =============================================================================
# Dotfiles Bootstrap
# =============================================================================
# Detects the OS, installs dependencies, stows configs, and installs tools.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./install/common.sh
source "${DOTFILES_DIR}/install/common.sh"

# Packages stowed on every platform
COMMON_PACKAGES=(
    agents
    atuin
    editorconfig
    eza
    git
    mise
    nvim
    starship
    tmux
    yamllint
    zsh
)

# Packages stowed on macOS only
MAC_PACKAGES=(
    1Password
    ccstatusline
    claude
    claude-mem
    homebrew
    ghostty
    k9s
    skills
    ssh
    vscode
    worktrunk
    zed
)

detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        echo "${ID}"
    else
        print_error "Cannot detect OS"
        exit 1
    fi
}

# Install packages from Homebrew. This is called after stowing, so the Brewfile should be in place.
install_homebrew_packages() {
    if [[ ! -f "${HOME}/.Brewfile" ]]; then
        print_warning "No Brewfile found, skipping package installation"
        return
    fi

    print_status "Installing packages from Homebrew..."
    brew bundle install --file "${HOME}/.Brewfile"
    print_success "Homebrew packages installed"
}

setup_macos_1password() {
    if ! command -v op >/dev/null 2>&1; then
        print_warning "1Password CLI is not installed, skipping SSH agent socket"
        return
    fi

    mkdir -p "${HOME}/.1password"
    ln -sfn "${HOME}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock" \
        "${HOME}/.1password/agent.sock"
    print_success "1Password SSH agent socket linked"
}

install_linux_extras() {
    export PATH="${HOME}/.local/bin:${PATH}"
    install_starship
    install_1password_cli
}

main() {
    local os
    os=$(detect_os)
    print_status "Detected OS: ${os}"

    case "${os}" in
        macos)
            bash "${DOTFILES_DIR}/install/mac.sh"
            stow_packages "${COMMON_PACKAGES[@]}" "${MAC_PACKAGES[@]}"
            install_homebrew_packages
            setup_macos_1password
            ;;
        ubuntu|debian)
            bash "${DOTFILES_DIR}/install/ubuntu.sh"
            stow_packages "${COMMON_PACKAGES[@]}"
            install_linux_extras
            ;;
        *)
            print_error "Unsupported OS: ${os}. Supported: macos, ubuntu, debian"
            exit 1
            ;;
    esac

    install_tpm
    MISE_AQUA_GITHUB_ATTESTATIONS=false mise install
    print_success "Done! Restart your terminal or run: exec zsh"
}

main "$@"
