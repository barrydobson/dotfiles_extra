#=============================================================================
# Environment Variables & PATH
#=============================================================================

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export SSH_CONFIG_HOME="$XDG_CONFIG_HOME/ssh"
export SSH_DATA_HOME="$XDG_DATA_HOME/ssh"
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"

# Terminal settings
export TERM=xterm-256color
export EDITOR=nvim
export VISUAL=nvim
export LANG=en_GB.UTF-8
export LC_ALL="en_GB.UTF-8"

# Tool configurations
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export HOMEBREW_BUNDLE_FILE="$HOME/.Brewfile"
export WORDCHARS=''

# History configuration
HISTSIZE=10000000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

# History options
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history

#=============================================================================
# PATH Management
#=============================================================================

# Function to add to PATH if not already present
add_to_path() {
    local new_path="$1"
    case ":$PATH:" in
        *":$new_path:"*) ;;
        *) export PATH="$new_path:$PATH" ;;
    esac
}

# Add common paths
add_to_path "$HOME/.local/bin"
add_to_path "/opt/nvim/bin"
add_to_path "$HOME/go/bin"
add_to_path "/opt/homebrew/bin"

# Package manager paths
export PNPM_HOME="$HOME/.local/share/pnpm"
add_to_path "$PNPM_HOME"

#=============================================================================
# Local Environment
#=============================================================================

# Load local environment variables from ~/.env
load_env() {
    if [[ -s ~/.env ]]; then
        set -a  # automatically export all variables
        source ~/.env
        set +a  # turn off automatic export
    fi
}

load_env
