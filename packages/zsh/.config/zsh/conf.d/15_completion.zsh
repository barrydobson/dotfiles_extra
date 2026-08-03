#=============================================================================
# Completion System
#=============================================================================

# Case-insensitive, plus partial-word matching on . _ - boundaries
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# fzf-tab requires zsh's own menu to be off, and needs group-name/format set
# before it will render grouped results.
zstyle ':completion:*' menu no
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --height=60% --border
zstyle ':fzf-tab:complete:(cd|__zoxide_z|ls|eza):*' fzf-preview 'eza --icons --colour=always --long --header $realpath'
zstyle ':fzf-tab:complete:git-(add|diff|restore|checkout):*' fzf-preview 'git diff --color=always -- $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $word'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview 'ps -p $word -o comm=,args='
zstyle ':fzf-tab:complete:(-command-|export|unset):*' fzf-preview 'echo ${(P)word}'

#=============================================================================
# Tool Completions (Zinit)
# Generated once at install via atclone, refreshed explicitly with: zinit update
#=============================================================================

# kubectl — also registers 'k' alias completion via atload
zinit ice lucid wait has'kubectl' id-as'kubectl-completion' \
  atclone'kubectl completion zsh > _kubectl' \
  atpull'%atclone' as'completion' nocompile
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
# fpath
#=============================================================================
# $ZDOTDIR/functions is already on fpath from .zshrc (it has to be, so conf.d
# can autoload from it).

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

typeset -U fpath

#=============================================================================
# Autoload Functions
#=============================================================================

autoload -Uz zmv

if [[ -d "${ZDOTDIR}/functions" ]]; then
    for func in "${ZDOTDIR}"/functions/*(:t); do
        autoload -U $func
    done
fi

#=============================================================================
# Initialise Completion System
#=============================================================================

ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

# Skip the full fpath scan when the dump file is less than 24 hours old (-C).
# On the first shell of a new day (or after zinit update), a full rebuild runs.
autoload -Uz compinit
if [[ -n ${ZSH_COMPDUMP}(#qN.mh-24) ]]; then
    compinit -C -i -d "$ZSH_COMPDUMP"
else
    compinit -i -d "$ZSH_COMPDUMP"
fi

# Replay Zinit compdefs (must run after compinit)
zinit cdreplay -q
