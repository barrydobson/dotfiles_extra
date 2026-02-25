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

# zsh-completions must load synchronously: its fpath additions must precede compinit (15_completion.zsh)
zinit light zsh-users/zsh-completions

# Configure autosuggestions before the plugin loads
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# UI plugins — turbo (deferred until after first prompt).
# Order matters: fzf-tab before autosuggestions and syntax-highlighting.
zinit wait lucid for \
    Aloxaf/fzf-tab \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting

# Oh My Zsh snippets — turbo (aliases and functions, safe to defer)
zinit wait lucid for \
    OMZP::aws \
    OMZP::command-not-found \
    OMZP::git \
    OMZP::sudo \
    OMZP::eza \
    OMZP::kubectl \
    OMZP::encode64

# Note: zinit cdreplay runs after compinit (in 15_completion.zsh)
