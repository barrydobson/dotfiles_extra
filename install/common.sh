#!/bin/bash

# =============================================================================
# Common functions shared across install scripts
# =============================================================================
# Source this file rather than executing it directly.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This script must be sourced, not executed directly." >&2
    exit 1
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if sudo is available without a password prompt
check_sudo_access() {
    if sudo -n true 2>/dev/null; then
        print_status "Sudo access available without password"
        return 0
    else
        print_warning "Sudo requires password - some operations may be skipped"
        print_warning "You may need to run some commands manually with sudo"
        return 1
    fi
}

_sudo() {
    if check_sudo_access; then
        sudo "$@"
    elif [[ $EUID -eq 0 ]]; then
        "$@"
    else
        print_warning "Sudo access not available, running command without sudo: $*"
        "$@"
    fi
}

# Install mise (https://mise.jdx.dev)
install_mise() {
    print_status "Installing mise..."

    if command -v mise >/dev/null 2>&1; then
        print_status "mise is already installed"
        return
    fi

    curl -fsSL https://mise.run | sh
    export PATH="${HOME}/.local/bin:${PATH}"
    print_success "mise installed"
}

install_1password_cli() {
  if command -v op >/dev/null 2>&1; then
    print_status "1Password CLI is already installed"
    return
  fi

  print_status "Installing 1Password CLI..."
  local arch="$(dpkg --print-architecture)"

  # Add the key for the 1Password apt repository:
  if [[ -f /usr/share/keyrings/1password-archive-keyring.gpg ]]; then
    print_status "1Password repository key already exists"
  else
    print_status "Adding 1Password repository key..."
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    print_success "1Password repository key added"
  fi

  if [[ -f /etc/apt/sources.list.d/1password.list ]]; then
    print_status "1Password repository already exists"
  else
    print_status "Adding 1Password repository..."
    echo "deb [arch=${arch} signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/${arch} stable main" | sudo tee /etc/apt/sources.list.d/1password.list
    print_success "1Password repository added"
  fi

  # Add the debsig-verify policy:
  sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
    sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

  # Install 1Password CLI:
  if command -v apt-get 2>&1 >/dev/null; then
    print_status "Installing 1Password CLI with apt-get..."
    sudo apt-get update
    sudo apt-get install -y --no-install-recommends 1password-cli
  elif command -v apk 2>&1 >/dev/null; then
    print_status "Installing 1Password CLI with apk..."
    apk add --no-cache 1password-cli
  else
    print_error "distribution not supported"
    exit 1
  fi
}

install_starship() {
    print_status "Installing Starship prompt..."

    if command -v starship >/dev/null 2>&1; then
        print_status "Starship is already installed"
        return
    fi

    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
    print_success "Starship prompt installed"
}

install_zoxide() {
    print_status "Installing zoxide (zsh directory jumper)..."

    if command -v zoxide >/dev/null 2>&1; then
        print_status "zoxide is already installed"
        return
    fi

    curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    print_success "zoxide installed"
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

# Common post-installation setup: default shell and standard directories
post_install_setup() {
    print_status "Performing post-installation setup..."

    mkdir -p "${HOME}/.local/bin"
    mkdir -p "${HOME}/.local/share"
    mkdir -p "${HOME}/.config"

    print_success "Post-installation setup completed"
}
