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

# ripgrep — search everything, including ignored, hidden and binary files.
# grep itself is left alone: rg uses a different regex dialect and different
# recursion and exit-code semantics, so aliasing it breaks pipelines.
if [ -x "$(command -v rg)" ]; then
  alias rga='rg -uuu'
fi

# procs - modern replacement for ps
if [ -x "$(command -v procs)" ]; then
  alias ps='procs'
fi
