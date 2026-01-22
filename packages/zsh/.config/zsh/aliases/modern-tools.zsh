#=============================================================================
# Modern CLI Tool Replacements
#=============================================================================
# Conditionally alias traditional tools to modern alternatives when available

# eza - modern replacement for ls
if [ "$(command -v eza)" ]; then
    unalias -m "ls"
    unalias -m "ll"
    alias ls="eza --icons --header --group --git --long"
    alias ls.tree="eza --header --group --tree --level=2  --git --long --icons"
    alias ll='eza --header --group --long --all'
    alias ll.tree='eza --header --group --tree --level=2  --git --long --icons --all'
    alias la='eza --icons --header --group --git --long --all --ignore-glob .DS_Store'
    alias tree="eza --tree --all --git-ignore"
fi

# bat - modern replacement for cat with syntax highlighting
if [ -x "$(command -v bat)" ]; then
  alias cat="bat"
fi

# btop - modern replacement for top
if [ "$(command -v btop)" ]; then
    alias top='btop'
fi

# fd - modern replacement for find
if [ -x "$(command -v fd)" ]; then
  alias find='fd'
fi

# ripgrep - modern replacement for grep
if [ -x "$(command -v rg)" ]; then
  alias rga='rg -uuu'
  alias grep='rga'
fi

# dust - modern replacement for du
if [ -x "$(command -v dust)" ]; then
  alias du='dust'
fi

# duf - modern replacement for df
if [ -x "$(command -v duf)" ]; then
  alias df='duf'
fi

# procs - modern replacement for ps
if [ -x "$(command -v procs)" ]; then
  alias ps='procs'
fi

# doge - modern replacement for dig/dog
if [ -x "$(command -v doge)" ]; then
  alias dig='doge'
  alias dog='doge'
fi
