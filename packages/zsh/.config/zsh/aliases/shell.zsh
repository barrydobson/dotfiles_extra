#=============================================================================
# Shell Navigation & Safety
#=============================================================================

# Quick navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"                 # Go to previous directory

# Safety nets
if command -v trash >/dev/null 2>&1; then
    alias rm="trash"             # Recoverable; use `command rm` to really delete
else
    alias rm="rm -i"             # Confirm before removing
fi
alias cp="cp -i"                 # Confirm before overwriting
alias mv="mv -i"                 # Confirm before overwriting
alias ln="ln -i"                 # Confirm before overwriting
