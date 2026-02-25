#=============================================================================
# System & Utilities
#=============================================================================

# System
alias update="sudo apt update && sudo apt upgrade -y"
alias myip="curl -s https://ipinfo.io/ip"

# Utility
alias weather="curl wttr.in/Wigan"           # Check weather
alias path="echo $PATH | tr ':' '\n'"       # Print PATH in readable format
alias ports="lsof -i -P -n | grep LISTEN"   # Show listening ports
