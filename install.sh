#!/bin/bash

# =============================================================================
# Dotfiles Installation Dispatcher
# =============================================================================
# Detects OS and runs the appropriate platform-specific installation script

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

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/install"

# Detect OS
OS_NAME=$(uname -s)
OS_NAME=$(echo "${OS_NAME}" | tr '[:upper:]' '[:lower:]')
OS_ARCH=$(uname -m)

print_status "Detected OS: ${OS_NAME} (${OS_ARCH})"

# Determine which installation script to run
case "${OS_NAME}" in
    darwin)
        print_status "Running macOS installation script..."
        INSTALL_SCRIPT="${INSTALL_DIR}/mac.sh"
        ;;
    linux)
        # Detect Linux distribution
        if [[ -f /etc/os-release ]]; then
            # shellcheck disable=SC1091
            source /etc/os-release
            DISTRO="${ID:-unknown}"

            case "${DISTRO}" in
                ubuntu|debian)
                    print_status "Running Ubuntu/Debian installation script..."
                    INSTALL_SCRIPT="${INSTALL_DIR}/ubuntu.sh"
                    ;;
                arch|manjaro)
                    print_status "Running Arch Linux installation script..."
                    INSTALL_SCRIPT="${INSTALL_DIR}/arch-linux.sh"
                    ;;
                *)
                    print_warning "Distribution '${DISTRO}' not directly supported"
                    print_status "Attempting Ubuntu script (may work for Debian-based distros)..."
                    INSTALL_SCRIPT="${INSTALL_DIR}/ubuntu.sh"
                    ;;
            esac
        else
            print_error "Cannot detect Linux distribution (/etc/os-release not found)"
            print_status "Please run the appropriate script manually from ${INSTALL_DIR}/"
            exit 1
        fi
        ;;
    *)
        print_error "Unsupported operating system: ${OS_NAME}"
        print_status "Supported systems: macOS (darwin), Linux (Ubuntu/Debian/Arch)"
        print_status "Please run the appropriate script manually from ${INSTALL_DIR}/"
        exit 1
        ;;
esac

# Verify the installation script exists
if [[ ! -f "${INSTALL_SCRIPT}" ]]; then
    print_error "Installation script not found: ${INSTALL_SCRIPT}"
    exit 1
fi

# Make sure the script is executable
chmod +x "${INSTALL_SCRIPT}"

# Run the platform-specific installation script
print_status "Executing: ${INSTALL_SCRIPT}"
echo ""
exec "${INSTALL_SCRIPT}" "$@"
