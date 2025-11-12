#!/bin/bash

# =============================================================================
# Arch Linux Dotfiles Dependencies Installation Script
# =============================================================================
# This script installs all the required dependencies for the dotfiles to work
# properly on Arch Linux. It handles both pacman and AUR installations.

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

# Check if we can run sudo without password
check_sudo_access() {
    if sudo -n true 2>/dev/null; then
        print_status "Sudo access available without password"
        return 0
    else
        print_warning "Sudo requires password - some operations will be skipped"
        print_warning "You may need to run some commands manually with sudo"
        return 1
    fi
}

# Check if running on Arch Linux
check_arch_linux() {
    if [[ ! -f /etc/arch-release ]]; then
        print_error "This script is designed for Arch Linux only."
        exit 1
    fi
}

# Check if yay is installed
check_yay() {
    if command -v yay >/dev/null 2>&1; then
        print_status "yay AUR helper found"
        return 0
    else
        print_warning "yay AUR helper not found"
        return 1
    fi
}

# Install yay if not present
install_yay() {
    print_status "Installing yay AUR helper..."

    # Install base-devel and git if not already installed
    if check_sudo_access; then
        sudo pacman -S --needed --noconfirm base-devel git

        # Clone and build yay
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
        rm -rf /tmp/yay

        print_success "yay installed successfully"
    else
        print_warning "Cannot install base-devel and git automatically"
        print_warning "Please run: sudo pacman -S --needed --noconfirm base-devel git"
        print_warning "Then manually install yay from AUR"
    fi
}

# Update system packages
update_system() {
    print_status "Updating system packages..."
    if check_sudo_access; then
        sudo pacman -Syu --noconfirm
        print_success "System updated"
    else
        print_warning "Cannot update system automatically"
        print_warning "Please run: sudo pacman -Syu --noconfirm"
    fi
}

# Install packages from official repositories
install_official_packages() {
    print_status "Installing packages from official repositories..."

    # Core system tools
    local core_packages=(
        "zsh"                # Z shell
        "make"               # Build tool
        "stow"               # Symlink farm manager
        "git"                # Version control
        "curl"               # HTTP client
        "wget"               # File downloader
    )

    # Modern CLI tools (replacements for standard tools)
    local cli_tools=(
        "bat"                # Enhanced cat with syntax highlighting
        "eza"                # Modern ls replacement
        "zoxide"             # Smart cd command
        "ripgrep"            # Fast grep replacement
        "fd"                 # Fast find replacement
        "dust"               # Better du replacement
        "duf"                # Better df replacement
        "btop"               # Better top replacement
        "fzf"                # Fuzzy finder
    )

    # Development tools
    local dev_tools=(
        "neovim"             # Text editor
        "tmux"               # Terminal multiplexer
        "direnv"             # Environment switcher
        "lazygit"            # Git TUI
        "stylua"             # Lua formatter
        "lua-language-server" # Lua LSP
    )

    # Terminal emulators
    local terminals=(
        "alacritty"          # GPU-accelerated terminal
        "ghostty"            # Modern terminal emulator
    )

    # Programming languages and runtimes
    local languages=(
        "nodejs"             # JavaScript runtime
        "npm"                # Node package manager
        "yarn"               # Alternative Node package manager
        "python"             # Python interpreter
        "python-pip"         # Python package manager
    )

    # Fonts
    local fonts=(
        "ttf-jetbrains-mono-nerd" # JetBrains Mono Nerd Font
    )

    # Combine all packages
    local all_packages=(
        "${core_packages[@]}"
        "${cli_tools[@]}"
        "${dev_tools[@]}"
        "${terminals[@]}"
        "${languages[@]}"
        "${fonts[@]}"
    )

    # Install packages
    if check_sudo_access; then
        for package in "${all_packages[@]}"; do
            if pacman -Qi "${package}" >/dev/null 2>&1; then
                print_status "${package} is already installed"
            else
                print_status "Installing ${package}..."
                sudo pacman -S --needed --noconfirm "${package}"
            fi
        done
    else
        print_warning "Cannot install packages automatically"
        print_warning "Please run the following commands manually:"
        for package in "${all_packages[@]}"; do
            if ! pacman -Qi "${package}" >/dev/null 2>&1; then
                echo "sudo pacman -S --needed --noconfirm ${package}"
            fi
        done
    fi

    print_success "Official packages installed"
}

# Install AUR packages
install_aur_packages() {
    print_status "Installing AUR packages..."

    local aur_packages=(
        "git-delta"          # Better git diff tool
    )

    if check_yay; then
        for package in "${aur_packages[@]}"; do
            if yay -Qi "${package}" >/dev/null 2>&1; then
                print_status "${package} is already installed"
            else
                print_status "Installing ${package} from AUR..."
                if check_sudo_access; then
                    yay -S --needed --noconfirm "${package}"
                else
                    print_warning "Cannot install ${package} from AUR automatically (requires sudo)"
                    print_warning "Please run: yay -S --needed --noconfirm ${package}"
                fi
            fi
        done
    else
        print_warning "yay not available, skipping AUR packages"
        print_warning "Please install manually: ${aur_packages[*]}"
    fi

    print_success "AUR packages processed"
}

# Install additional Node.js tools
install_node_tools() {
    print_status "Installing Node.js global packages..."

    # Check if npm is available
    if command -v npm >/dev/null 2>&1; then
        # Install pnpm globally
        if ! command -v pnpm >/dev/null 2>&1; then
            print_status "Installing pnpm..."
            npm install -g pnpm
        else
            print_status "pnpm is already installed"
        fi
    else
        print_warning "npm not available, skipping Node.js tools"
    fi

    print_success "Node.js tools processed"
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

# Post-installation setup
post_install_setup() {
    print_status "Performing post-installation setup..."

    # Change default shell to zsh if not already set
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

    print_success "Post-installation setup completed"
}

# Main execution
main() {
    print_status "Starting Arch Linux dotfiles dependencies installation..."

    # Check prerequisites
    check_arch_linux

    # Install yay if not present
    if ! check_yay; then
        install_yay
    fi

    # Update system
    update_system

    # Install packages
    install_official_packages
    install_aur_packages

    # Configure tools
    install_node_tools
    install_catppuccin_bat
    install_rust

    # Install additional tools
    install_zinit
    install_fzf
    install_tpm

    # Post-installation setup
    post_install_setup

    print_success "All dependencies installed successfully!"
    print_status "You can now run 'make stow' to set up your dotfiles."
    print_warning "Note: You may need to restart your terminal or log out/in for all changes to take effect."
}

# Run main function
main "$@"
