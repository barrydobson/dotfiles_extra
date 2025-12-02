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
alias rm="rm -i"                 # Confirm before removing
alias cp="cp -i"                 # Confirm before overwriting
alias mv="mv -i"                 # Confirm before overwriting
alias ln="ln -i"                 # Confirm before overwriting
