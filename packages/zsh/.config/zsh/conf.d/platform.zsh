#=============================================================================
# Platform-Specific Configuration
#=============================================================================

OS=$(uname)

# OS-specific initialization
case $OS in
    "Darwin")
        # macOS specific setup - handle both Intel and Apple Silicon
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        # 1Password SSH agent
        if [[ -S "$HOME/.1password/agent.sock" ]]; then
            export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
        fi
        ;;
    "Linux")
        # Linux specific setup
        if [ -f "/etc/os-release" ]; then
            . "/etc/os-release"
        fi

        # 1Password SSH agent (Arch Linux)
        if [[ -f "/etc/arch-release" ]] && [[ -S "$HOME/.1password/agent.sock" ]]; then
            export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
        fi
        ;;
esac
