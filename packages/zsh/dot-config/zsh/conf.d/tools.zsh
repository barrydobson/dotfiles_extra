#=============================================================================
# Tool Initialization
#=============================================================================

# Initialize zoxide (smart cd)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# Initialize starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Initialize atuin (shell history)
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# Initialize direnv (per-directory environment variables)
if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

# Initialize fzf (fuzzy finder)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# Configure fd for fzf
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

    _fzf_compgen_path() {
        fd --hidden --exclude .git . "$1"
    }

    _fzf_compgen_dir() {
        fd --type=d --hidden --exclude .git . "$1"
    }
fi

#=============================================================================
# Version Managers (Lazy-Loaded)
#=============================================================================

# Lazy-load NVM (Node Version Manager) - only loads when nvm/node/npm is first used
# This saves 200-500ms on shell startup
if [[ -d "$HOME/.config/nvm" ]]; then
    export NVM_DIR="$HOME/.config/nvm"

    # Lazy-load function
    nvm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
    }

    # Also lazy-load node, npm, npx
    node() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        node "$@"
    }

    npm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        npm "$@"
    }

    npx() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
        npx "$@"
    }
fi

# Load asdf or other version manager environment
# Note: This appears to be loading from $HOME/.local/bin/env
# If this causes issues or is no longer needed, it can be removed
if [[ -f "$HOME/.local/bin/env" ]]; then
    source "$HOME/.local/bin/env"
fi

#=============================================================================
# Load Aliases
#=============================================================================

# Load all alias files
if [[ -d $ZDOTDIR/aliases ]]; then
    for alias_file in $ZDOTDIR/aliases/*.zsh; do
        [[ -f "$alias_file" ]] && source "$alias_file"
    done
fi
