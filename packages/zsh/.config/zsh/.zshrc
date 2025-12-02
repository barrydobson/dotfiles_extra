# shellcheck disable=all

#=============================================================================
# Zsh Configuration - Modular Setup
#=============================================================================
#
# Configuration is split into focused files in conf.d/:
# - platform.zsh    : OS-specific setup (macOS, Linux, etc.)
# - environment.zsh : Environment variables, PATH, history
# - plugins.zsh     : Zinit and plugin management
# - completion.zsh  : Completion system and setup
# - tools.zsh       : Tool initialization (zoxide, starship, fzf, etc.)
#
# Aliases are in aliases/*.zsh (sourced from tools.zsh)
#=============================================================================

# Source configuration files in order
if [[ -d $ZDOTDIR/conf.d ]]; then
    # Load in specific order for dependencies
    source "$ZDOTDIR/conf.d/platform.zsh"
    source "$ZDOTDIR/conf.d/environment.zsh"
    source "$ZDOTDIR/conf.d/plugins.zsh"
    source "$ZDOTDIR/conf.d/completion.zsh"
    source "$ZDOTDIR/conf.d/tools.zsh"
fi
