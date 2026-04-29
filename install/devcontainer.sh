#!/bin/bash

# =============================================================================
# Devcontainer Bootstrap
# =============================================================================
# Invoked by VSCode's dotfiles.repository setting after the container starts.
# Runs as the remote (non-root) user. Assumes system prerequisites are already
# present in the image — see DEVCONTAINERS.md.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=./common.sh
source "${DOTFILES_DIR}/install/common.sh"

DEVCONTAINER_PACKAGES=(
    starship
    zsh
    claude
    ccstatusline
)

check_prerequisites() {
    local required=(zsh curl git stow)
    local missing=()

    for cmd in "${required[@]}"; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            missing+=("${cmd}")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        print_error "Missing required commands: ${missing[*]}"
        print_error "These must be installed in the container image. See DEVCONTAINERS.md."
        exit 1
    fi

    print_success "All prerequisites present"
}

stow_packages() {
    local packages=("$@")
    print_status "Stowing: ${packages[*]}"
    cd "${DOTFILES_DIR}/packages" && stow -v -R -t "${HOME}" "${packages[@]}"
    cd "${DOTFILES_DIR}"
    print_success "Packages stowed"
}

main() {
    print_status "Configuring devcontainer dotfiles..."
    check_prerequisites
    post_install_setup
    stow_packages "${DEVCONTAINER_PACKAGES[@]}"
    print_success "Done. Open a new zsh shell to load the configuration."
}

main "$@"
