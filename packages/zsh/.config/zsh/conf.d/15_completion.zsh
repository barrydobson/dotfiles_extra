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

#=============================================================================
# fpath Setup
#=============================================================================

fpath=(
    $HOME/.config/zsh/functions
    $HOME/.config/zsh/widgets
    "${fpath[@]}"
)

typeset -U fpath

# Brew completions — $HOMEBREW_PREFIX is already set by 00_platform.zsh (no subprocess)
if [[ -n "$HOMEBREW_PREFIX" ]]; then
    fpath=($HOMEBREW_PREFIX/share/zsh-completions $HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
fi

# Docker Desktop writes completions here separately from the CLI
if [[ -d "$HOME/.docker/completions" ]]; then
    fpath=($HOME/.docker/completions $fpath)
fi

if [[ -d "$HOME/.zsh/completion" ]]; then
    fpath=($HOME/.zsh/completion $fpath)
fi

#=============================================================================
# Tool Completions (Zinit)
# Generated once at install via atclone, refreshed explicitly with: zinit update
#=============================================================================

# kubectl — also registers 'k' alias completion via atload
zinit ice lucid wait has'kubectl' id-as'kubectl-completion' \
  atclone'kubectl completion zsh > _kubectl' \
  atpull'%atclone' as'completion' nocompile \
  atload'compdef k=kubectl'
zinit light zdharma-continuum/null

zinit ice lucid wait has'helm' id-as'helm-completion' \
  atclone'helm completion zsh > _helm' \
  atpull'%atclone' as'completion' nocompile
zinit light zdharma-continuum/null

zinit ice lucid wait has'mise' id-as'mise-completion' \
  atclone'mise completion zsh > _mise' \
  atpull'%atclone' as'completion' nocompile
zinit light zdharma-continuum/null

zinit ice lucid wait has'atuin' id-as'atuin-completion' \
  atclone'atuin gen-completions -s zsh > _atuin' \
  atpull'%atclone' as'completion' nocompile
zinit light zdharma-continuum/null

zinit ice lucid wait has'docker' id-as'docker-completion' \
  atclone'docker completion zsh > _docker' \
  atpull'%atclone' as'completion' nocompile
zinit light zdharma-continuum/null

zinit ice lucid wait has'uv' id-as'uv-completion' \
  atclone'uv generate-shell-completion zsh > _uv' \
  atpull'%atclone' as'completion' nocompile
zinit light zdharma-continuum/null

zinit ice lucid wait has'uvx' id-as'uvx-completion' \
  atclone'uvx --generate-shell-completion zsh > _uvx' \
  atpull'%atclone' as'completion' nocompile
zinit light zdharma-continuum/null

#=============================================================================
# Autoload Functions & Widgets
#=============================================================================

autoload -Uz zmv

if [[ -d $HOME/.config/zsh/functions ]]; then
    for func in $HOME/.config/zsh/functions/*(:t); do
        autoload -U $func
    done
fi

if [[ -d $HOME/.config/zsh/widgets ]]; then
    for func in $HOME/.config/zsh/widgets/*(:t); do
        autoload -U $func
        zle -N $func
    done
fi

#=============================================================================
# Initialise Completion System
#=============================================================================

# Skip the full fpath scan when the dump file is less than 24 hours old (-C).
# On the first shell of a new day (or after zinit update), a full rebuild runs.
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh-24) ]]; then
    compinit -C -i -d ~/.zcompdump
else
    compinit -i -d ~/.zcompdump
fi

# Replay Zinit compdefs (must run after compinit)
zinit cdreplay -q
