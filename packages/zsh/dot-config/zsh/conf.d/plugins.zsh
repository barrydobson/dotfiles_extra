#=============================================================================
# Plugin Management (Zinit)
#=============================================================================

# Zinit setup with error handling
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME" || {
        echo "Failed to clone zinit repository"
        return 1
    }
fi

# Source zinit with error handling
if [ -f "${ZINIT_HOME}/zinit.zsh" ]; then
    source "${ZINIT_HOME}/zinit.zsh"
else
    echo "zinit.zsh not found"
    return 1
fi

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Configure autosuggestions
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Oh My Zsh snippets
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::eza
zinit snippet OMZP::asdf
zinit snippet OMZP::kubectl
zinit snippet OMZP::encode64

# Note: zinit cdreplay runs after compinit (in completion.zsh)
