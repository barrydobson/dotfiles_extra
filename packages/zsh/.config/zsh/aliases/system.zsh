#=============================================================================
# System & Utilities
#=============================================================================

# System
if command -v apt >/dev/null 2>&1; then
    alias update="sudo apt update && sudo apt upgrade -y"
elif command -v brew >/dev/null 2>&1; then
    alias update="brew update && brew upgrade"
fi
alias myip="curl -s https://ipinfo.io/ip"

# Utility
alias weather="curl wttr.in/Wigan"           # Check weather
alias path='echo $PATH | tr ":" "\n"'       # Print PATH in readable format
alias ports="lsof -i -P -n | grep LISTEN"   # Show listening ports
