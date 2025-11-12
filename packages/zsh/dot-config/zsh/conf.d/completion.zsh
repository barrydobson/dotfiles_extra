#=============================================================================
# Completion System
#=============================================================================

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Add custom function/widget paths to fpath
fpath=(
    $HOME/.config/zsh/functions
    $HOME/.config/zsh/widgets
    "${fpath[@]}"
)

# Remove duplicates automatically
typeset -U fpath

# Add brew completions if available (consolidated)
if command -v brew &>/dev/null; then
    fpath=($(brew --prefix)/share/zsh-completions $fpath)
    fpath=($(brew --prefix)/share/zsh/site-functions $fpath)
fi

# Add Docker completions if available
if [[ -d "$HOME/.docker/completions" ]]; then
    fpath=($HOME/.docker/completions $fpath)
fi

# Add custom zsh completions
if [[ -d "$HOME/.zsh/completion" ]]; then
    fpath=($HOME/.zsh/completion $fpath)
fi

#=============================================================================
# Enhanced Completion Setup (Cached)
#=============================================================================

# Generate completions for modern tools with caching to avoid slow regeneration on every shell start
setup_completions() {
    local comp_dir="$HOME/.local/share/zsh/completions"
    local comp_cache="$comp_dir/.cache_timestamp"

    mkdir -p "$comp_dir"

    # Check if cache is less than 24 hours old
    if [[ -f "$comp_cache" ]]; then
        local cache_age=$(( $(date +%s) - $(stat -f %m "$comp_cache" 2>/dev/null || stat -c %Y "$comp_cache" 2>/dev/null || echo 0) ))
        if [[ $cache_age -lt 86400 ]]; then
            # Cache is fresh, just add to fpath and return
            fpath=("$comp_dir" $fpath)
            return 0
        fi
    fi

    # Cache is stale or missing, regenerate completions

    # Kubernetes & containers
    command -v kubectl >/dev/null 2>&1 && kubectl completion zsh > "$comp_dir/_kubectl"
    command -v docker >/dev/null 2>&1 && docker completion zsh > "$comp_dir/_docker"
    command -v helm >/dev/null 2>&1 && helm completion zsh > "$comp_dir/_helm"

    # Uncomment if you use these tools:
    # command -v kubectx >/dev/null 2>&1 && kubectx completion zsh > "$comp_dir/_kubectx"
    # command -v kubens >/dev/null 2>&1 && kubens completion zsh > "$comp_dir/_kubens"
    # command -v terragrunt >/dev/null 2>&1 && terragrunt completion zsh > "$comp_dir/_terragrunt"

    # AWS tools (will be set up by OMZP::aws plugin in plugins.zsh)
    # Note: AWS completions are handled by Oh My Zsh aws plugin

    # JavaScript package managers
    command -v pnpm >/dev/null 2>&1 && pnpm install-completion >/dev/null 2>&1

    # Add completion directory to fpath
    fpath=("$comp_dir" $fpath)

    # Update cache timestamp
    touch "$comp_cache"
}

# Set up modern tool completions (before compinit)
setup_completions

# Load custom functions
autoload -Uz zmv

if [[ -d $HOME/.config/zsh/functions ]]; then
    for func in $HOME/.config/zsh/functions/*(:t); do
        autoload -U $func
    done
fi

# Load custom widgets
if [[ -d $HOME/.config/zsh/widgets ]]; then
    for func in $HOME/.config/zsh/widgets/*(:t); do
        autoload -U $func
        zle -N $func
    done
fi

# Initialize completion system
autoload -Uz compinit
compinit -i -d ~/.zcompdump

# Replay Zinit compdefs (must run after compinit)
if command -v zinit >/dev/null 2>&1; then
    zinit cdreplay -q
fi

# Keybindings
bindkey -e  # Use emacs keybindings
# Option + Left/Right = move by word
bindkey '^[b' backward-word
bindkey '^[f' forward-word
# Home/End (used by Cmd+Left/Right)
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

#=============================================================================
# Utility Functions
#=============================================================================

# Smart package manager runner - detects lockfile and uses appropriate tool
run() {
    if [[ -f pnpm-lock.yaml ]]; then
        command pnpm "$@"
    elif [[ -f yarn.lock ]]; then
        command yarn "$@"
    elif [[ -f package-lock.json ]]; then
        command npm "$@"
    else
        command pnpm "$@"  # Default to pnpm
    fi
}
