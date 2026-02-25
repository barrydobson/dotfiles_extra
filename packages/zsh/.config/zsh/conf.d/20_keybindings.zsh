#=============================================================================
# Keybindings
#=============================================================================

bindkey -e  # Use emacs keybindings

# Option + Left/Right = move by word
bindkey '^[b' backward-word
bindkey '^[f' forward-word

# Home/End (used by Cmd+Left/Right)
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
