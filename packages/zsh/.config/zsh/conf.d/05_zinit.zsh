#=============================================================================
# Plugin Management (Zinit)
#=============================================================================

# Zinit setup with error handling
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

# Source zinit with error handling
if [ -f "${ZINIT_HOME}/zinit.zsh" ]; then
    source "${ZINIT_HOME}/zinit.zsh"
else
    echo "zinit.zsh not found"
    return 1
fi

# zsh-completions must load synchronously: its fpath additions must precede
# compinit (15_completion.zsh). blockf stops it appending to fpath itself.
zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# Configure autosuggestions before the plugin loads
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# UI plugins — turbo (deferred until after first prompt).
# Order matters: fzf-tab before autosuggestions and syntax-highlighting.
# autosuggestions needs the atload kicker, or it stays dead until a keypress.
zinit wait lucid for \
    Aloxaf/fzf-tab \
  atload'_zsh_autosuggest_start' \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting

# Oh My Zsh snippets — turbo (aliases and functions, safe to defer)
# OMZP::git is deliberately absent: it redefines gp/gl/gc/gca after
# aliases/git.zsh has been sourced, silently swapping pull and push.
zinit wait lucid for \
    OMZP::sudo \
    OMZP::encode64

if command -v eza >/dev/null 2>&1; then
  zinit wait lucid for OMZP::eza
fi

if command -v kubectl >/dev/null 2>&1; then
  zinit wait lucid for OMZP::kubectl
fi

if command -v aws >/dev/null 2>&1; then
  zinit wait lucid for OMZP::aws
fi

# Note: zinit cdreplay runs after compinit (in 15_completion.zsh)
