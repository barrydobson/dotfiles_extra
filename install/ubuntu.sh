#!/bin/bash

# =============================================================================
# Ubuntu Dotfiles Dependencies Installation Script
# =============================================================================
# This script installs all the required dependencies for the dotfiles to work
# properly on Ubuntu. It handles both apt and additional package installations.

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

# Function to detect system architecture
detect_arch() {
    ARCH=$(uname -m)
    case ${ARCH} in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        armv*)
            echo "armv6"
            ;;
        i386|i686)
            echo "x86"
            ;;
        *)
            print_error "Unsupported architecture: ${ARCH}"
            exit 1
            ;;
    esac
}

# Function to get latest GitHub release version
get_latest_release() {
    local repo=$1
    curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*'
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

# Check if running on a Debian-based system
check_debian_based() {
    if ! command -v apt >/dev/null 2>&1; then
        print_error "This script requires apt package manager (Debian/Ubuntu-based system)."
        exit 1
    fi

    # Warn if not Ubuntu/Debian, but don't fail
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        case "${ID}" in
            ubuntu|debian)
                print_status "Detected ${PRETTY_NAME:-${ID}}"
                ;;
            *)
                print_warning "Not Ubuntu/Debian, but apt is available. Proceeding..."
                ;;
        esac
    fi
}

# Update system packages
update_system() {
    print_status "Updating system packages..."
    if check_sudo_access; then
        sudo apt update && sudo apt upgrade -y
        print_success "System updated"
    else
        print_warning "Cannot update system automatically"
        print_warning "Please run: sudo apt update && sudo apt upgrade -y"
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
        "build-essential"    # Essential build tools
        "software-properties-common" # For adding PPAs
        "unzip"              # Archive tool
        "gcc"                # C compiler
        "libssl-dev"         # SSL development libraries
    )

    # Modern CLI tools (replacements for standard tools)
    local cli_tools=(
        "bat"                # Enhanced cat with syntax highlighting (note: command is batcat)
        "ripgrep"            # Fast grep replacement
        "fd-find"            # Fast find replacement (note: command is fdfind)
        "duf"                # Better df replacement
        "fzf"                # Fuzzy finder
        # "zoxide"             # Smart cd command
        "eza"                # Modern ls replacement (from newer Ubuntu versions)
    )

    # Development tools
    # local dev_tools=(
    #     "neovim"             # Text editor
    #     "tmux"               # Terminal multiplexer
    #     "direnv"             # Environment switcher
    #     "python3"            # Python interpreter
    #     "python3-pip"        # Python package manager
    #     "luarocks"           # Lua package manager
    # )

    # Terminal emulators
    # local terminals=(
    #     "alacritty"          # GPU-accelerated terminal
    # )

    # Fonts
    local fonts=(
        "fonts-jetbrains-mono" # JetBrains Mono font
    )

    # Git tools
    local git_tools=(
        "git-delta"          # Better git diffs
    )

    # Combine all packages
    local all_packages=(
        "${core_packages[@]}"
        "${cli_tools[@]}"
        "${dev_tools[@]}"
        "${terminals[@]}"
        "${fonts[@]}"
        "${git_tools[@]}"
    )

    # Install packages
    if check_sudo_access; then
        for package in "${all_packages[@]}"; do
            if dpkg -l | grep -q "^ii  ${package} "; then
                print_status "${package} is already installed"
            else
                print_status "Installing ${package}..."
                if ! sudo apt install -y "${package}" 2>/dev/null; then
                    print_warning "Failed to install ${package}, it may not be available in repositories"
                fi
            fi
        done
    else
        print_warning "Cannot install packages automatically"
        print_warning "Please run the following commands manually:"
        for package in "${all_packages[@]}"; do
            if ! dpkg -l | grep -q "^ii  ${package} "; then
                echo "sudo apt install -y ${package}"
            fi
        done
    fi

    print_success "Official packages installation completed"
}

# Install Node.js via NodeSource
install_nodejs() {
    print_status "Installing Node.js via NodeSource..."

    if command -v node >/dev/null 2>&1; then
        print_status "Node.js is already installed ($(node --version))"
        return 0
    fi

    if check_sudo_access; then
        # Install Node.js 20.x
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
        print_success "Node.js installed"
    else
        print_warning "Cannot install Node.js automatically"
        print_warning "Please run: curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
        print_warning "Then run: sudo apt install -y nodejs"
    fi
}

# Install additional packages that need special handling
install_additional_packages() {
    print_status "Installing additional packages..."

    # Install eza if not available from apt
    if ! command -v eza >/dev/null 2>&1; then
        print_status "Installing eza from GitHub..."
        if check_sudo_access; then
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt update
            sudo apt install -y eza
            print_success "eza installed"
        else
            print_warning "Cannot install eza automatically - requires sudo"
        fi
    else
        print_status "eza is already installed"
    fi

    # Install dust (better du replacement)
    if ! command -v dust >/dev/null 2>&1; then
        print_status "Installing dust..."
        local dust_version="0.8.6"
        wget -O /tmp/dust.deb "https://github.com/bootandy/dust/releases/download/v${dust_version}/du-dust_${dust_version}_amd64.deb"
        if check_sudo_access; then
            sudo dpkg -i /tmp/dust.deb
            rm /tmp/dust.deb
            print_success "dust installed"
        else
            print_warning "Cannot install dust automatically - requires sudo"
            print_warning "Please run: sudo dpkg -i /tmp/dust.deb"
        fi
    else
        print_status "dust is already installed"
    fi

    # Install btop (better top replacement)
    if ! command -v btop >/dev/null 2>&1; then
        print_status "Installing btop..."
        if check_sudo_access; then
            if ! sudo apt install -y btop 2>/dev/null; then
                print_warning "btop not available in repositories, installing from snap..."
                sudo snap install btop
            fi
            print_success "btop installed"
        else
            print_warning "Cannot install btop automatically"
            print_warning "Please run: sudo apt install -y btop"
        fi
    else
        print_status "btop is already installed"
    fi

    # Install lazygit
    if ! command -v lazygit >/dev/null 2>&1; then
        print_status "Installing lazygit..."
        local lazygit_version
        lazygit_version=$(get_latest_release "jesseduffield/lazygit")
        local arch_name
        arch_name=$(detect_arch)
        wget -O /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${lazygit_version}/lazygit_${lazygit_version}_Linux_${arch_name}.tar.gz"
        tar -xzf /tmp/lazygit.tar.gz -C /tmp
        if check_sudo_access; then
            sudo mv /tmp/lazygit /usr/local/bin/
            rm /tmp/lazygit.tar.gz
            print_success "lazygit installed"
        else
            print_warning "Cannot install lazygit automatically - requires sudo"
            print_warning "Please run: sudo mv /tmp/lazygit /usr/local/bin/"
        fi
    else
        print_status "lazygit is already installed"
    fi

    # Install yarn globally
    if ! command -v yarn >/dev/null 2>&1; then
        print_status "Installing yarn..."
        if command -v npm >/dev/null 2>&1; then
            npm install -g yarn
            print_success "yarn installed via npm"
        else
            print_warning "Cannot install yarn - npm not available"
        fi
    else
        print_status "yarn is already installed"
    fi
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

        # Install corepack
        print_status "Installing corepack..."
        npm install -g corepack
    else
        print_warning "npm not available, skipping Node.js tools"
    fi

    print_success "Node.js tools processed"
}

# Install and configure Catppuccin theme for bat
install_catppuccin_bat() {
    print_status "Installing Catppuccin themes for bat..."

    # Check if bat is installed (note: command is batcat on Ubuntu)
    local bat_cmd="bat"
    if command -v batcat >/dev/null 2>&1; then
        bat_cmd="batcat"
    fi

    if command -v "$bat_cmd" >/dev/null 2>&1; then
        # Create bat themes directory
        local bat_themes_dir
        bat_themes_dir="$(${bat_cmd} --config-dir)/themes"
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
            ${bat_cmd} cache --build
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

# Install Lua Language Server
install_lua_lsp() {
    print_status "Installing Lua Language Server..."

    if ! command -v lua-language-server >/dev/null 2>&1; then
        print_status "Building Lua Language Server from git..."

        # Install build dependencies
        if check_sudo_access; then
            sudo apt install -y lua5.4 liblua5.4-dev ninja-build
        fi

        # Clone and build lua-language-server
        local temp_dir="/tmp/lua-language-server"
        if [[ -d "${temp_dir}" ]]; then
            rm -rf "${temp_dir}"
        fi

        git clone --depth=1 --recursive https://github.com/LuaLS/lua-language-server "${temp_dir}"
        cd "${temp_dir}"

        # Build the project
        ./make.sh

        # Install to /usr/local/bin
        if check_sudo_access; then
            sudo mkdir -p /usr/local/share/lua-language-server
            sudo cp -r bin main.lua debugger.lua locale meta script /usr/local/share/lua-language-server/

            # Create wrapper script in /usr/local/bin
            sudo tee /usr/local/bin/lua-language-server > /dev/null << 'EOF'
#!/bin/bash
exec /usr/local/share/lua-language-server/bin/lua-language-server -E /usr/local/share/lua-language-server/main.lua "$@"
EOF
            sudo chmod +x /usr/local/bin/lua-language-server

            print_success "Lua Language Server installed"
        else
            print_warning "Cannot install Lua Language Server automatically - requires sudo"
            print_warning "Please run the following commands manually:"
            print_warning "sudo cp bin/lua-language-server /usr/local/bin/"
            print_warning "sudo mkdir -p /usr/local/share/lua-language-server"
            print_warning "sudo cp -r main.lua debugger.lua locale meta script /usr/local/share/lua-language-server/"
        fi

        # Clean up
        cd - > /dev/null
        rm -rf "${temp_dir}"
    else
        print_status "Lua Language Server is already installed"
    fi
}

# Install stylua (Lua formatter)
install_stylua() {
    print_status "Installing stylua (Lua formatter)..."

    if ! command -v stylua >/dev/null 2>&1; then
        local stylua_version="0.19.1"
        wget -O /tmp/stylua.zip "https://github.com/JohnnyMorganz/StyLua/releases/download/v${stylua_version}/stylua-linux-x86_64.zip"
        unzip /tmp/stylua.zip -d /tmp
        if check_sudo_access; then
            sudo mv /tmp/stylua /usr/local/bin/
            sudo chmod +x /usr/local/bin/stylua
            rm /tmp/stylua.zip
            print_success "stylua installed"
        else
            print_warning "Cannot install stylua automatically - requires sudo"
            print_warning "Please run: sudo mv /tmp/stylua /usr/local/bin/ && sudo chmod +x /usr/local/bin/stylua"
        fi
    else
        print_status "stylua is already installed"
    fi
}

# Install JetBrains Mono Nerd Font
install_nerd_font() {
    print_status "Installing JetBrains Mono Nerd Font..."

    local font_dir="${HOME}/.local/share/fonts"
    local font_file="${font_dir}/JetBrainsMonoNerdFont-Regular.ttf"

    if [[ ! -f "${font_file}" ]]; then
        mkdir -p "${font_dir}"
        local font_version="3.4.0"
        wget -O /tmp/jetbrains-mono-nerd.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v${font_version}/JetBrainsMono.zip"
        unzip /tmp/jetbrains-mono-nerd.zip -d /tmp/jetbrains-mono-nerd
        cp /tmp/jetbrains-mono-nerd/*.ttf "${font_dir}/"
        fc-cache -fv
        rm -rf /tmp/jetbrains-mono-nerd.zip /tmp/jetbrains-mono-nerd
        print_success "JetBrains Mono Nerd Font installed"
    else
        print_status "JetBrains Mono Nerd Font is already installed"
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

    # Create symlinks for commands that have different names on Ubuntu
    if [[ ! -L "${HOME}/.local/bin/fd" ]] && command -v fdfind >/dev/null 2>&1; then
        ln -s "$(which fdfind)" "${HOME}/.local/bin/fd"
        print_status "Created symlink: fd -> fdfind"
    fi

    if [[ ! -L "${HOME}/.local/bin/bat" ]] && command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        ln -s "$(which batcat)" "${HOME}/.local/bin/bat"
        print_status "Created symlink: bat -> batcat"
    fi

    # Create global symlinks if we have sudo access and they don't exist
    if check_sudo_access; then
        if [[ ! -L "/usr/bin/bat" ]] && command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
            sudo ln -s "$(which batcat)" /usr/bin/bat
            print_status "Created global symlink: bat -> batcat"
        fi
    fi

    print_success "Post-installation setup completed"
}

# Main execution
main() {
    print_status "Starting dotfiles dependencies installation..."

    # Check prerequisites
    check_debian_based

    # Update system
    update_system

    # Install packages
    install_official_packages
    # install_nodejs
    install_additional_packages

    # Configure tools
    # install_node_tools
    install_catppuccin_bat
    # install_lua_lsp
    # install_stylua

    # Install additional tools
    install_zinit
    install_fzf
    # install_tpm
    install_nerd_font

    # Post-installation setup
    post_install_setup

    print_success "All dependencies installed successfully!"
    print_status "You can now run 'make stow' to set up your dotfiles."
    print_warning "Note: You may need to restart your terminal or log out/in for all changes to take effect."
    print_warning "Command aliases: Use 'fd' instead of 'fdfind' and 'bat' instead of 'batcat'"
}

# Run main function
main "$@"
