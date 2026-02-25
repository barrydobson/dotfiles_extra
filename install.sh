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
    homebrew
    ghostty
    k9s
    sketchybar
    ssh
    vscode
)

GLOBAL_NPM_PACKAGES=(
    ccstatusline
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

stow_packages() {
    local packages=("$@")
    print_status "Stowing: ${packages[*]}"
    cd "${DOTFILES_DIR}/packages" && stow -v -t "${HOME}" "${packages[@]}"
    cd "${DOTFILES_DIR}"
    print_success "Packages stowed"
}

# Install packages from Homebrew. This is called after stowing, so the Brewfile should be in place.
install_homebrew_packages() {
    print_status "Installing packages from Homebrew..."
    local brewfile_path=""

    if [[ -f "${HOME}/.Brewfile" ]]; then
        brewfile_path="${HOME}/.Brewfile"
    else
        print_warning "No Brewfile found, skipping package installation"
        return
    fi
    brew bundle check --file "${brewfile_path}" || brew bundle install --file "${brewfile_path}"

    print_success "Homebrew packages installation completed"
}

setup_macos_1password() {
    if command -v op >/dev/null 2>&1; then
        print_status "1Password CLI is available"
        return 0
    else
        print_warning "1Password CLI is not installed"
        return 1
    fi
    mkdir -p ~/.1password && ln -s ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ~/.1password/agent.sock
}

install_other_linux() {
    print_status "Installing tools from mise config..."
    export PATH="${HOME}/.local/bin:${PATH}"
    install_starship
    install_zoxide
    install_1password_cli
}

install_npm_packages() {
    print_status "Installing global npm packages..."
    mise exec node@lts -- npm install -g "${GLOBAL_NPM_PACKAGES[@]}"
    # if ! command -v npm >/dev/null 2>&1; then
    #     print_warning "npm is not installed, skipping global npm packages installation"
    #     return
    # fi
    # npm install -g "${GLOBAL_NPM_PACKAGES[@]}"
    print_success "Global npm packages installation completed"
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
            install_other_linux
            ;;
        arch|manjaro)
            bash "${DOTFILES_DIR}/install/arch-linux.sh"
            stow_packages "${COMMON_PACKAGES[@]}"
            install_other_linux
            ;;
        *)
            print_error "Unsupported OS: ${os}. Supported: macos, ubuntu, debian, arch"
            exit 1
            ;;
    esac

    install_zinit
    install_tpm
    MISE_AQUA_GITHUB_ATTESTATIONS=false mise install
    # install_npm_packages
    print_success "Done! Restart your terminal or run: exec zsh"
}

main "$@"
