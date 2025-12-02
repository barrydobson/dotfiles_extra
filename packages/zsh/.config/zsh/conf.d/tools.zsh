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
# Load Aliases
#=============================================================================

# Load all alias files
if [[ -d $ZDOTDIR/aliases ]]; then
    for alias_file in $ZDOTDIR/aliases/*.zsh; do
        [[ -f "$alias_file" ]] && source "$alias_file"
    done
fi

if [[ "$TERM_PROGRAM" == "vscode" ]] && command -v code >/dev/null 2>&1; then
  source "$(code --locate-shell-integration-path zsh)"
elif [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi

if [[ -x "$(command -v mise)" ]]; then
  export MISE_NODE_COREPACK=1

  eval "$(mise activate zsh)"
fi
