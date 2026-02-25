#=============================================================================
# PATH Management
#=============================================================================

# Function to add to PATH if not already present
add_to_path() {
    local new_path="$1"
    case ":$PATH:" in
        *":$new_path:"*) ;;
        *) export PATH="$new_path:$PATH" ;;
    esac
}

# Add common paths
add_to_path "$HOME/.local/bin"
add_to_path "/opt/nvim/bin"
add_to_path "$HOME/go/bin"
add_to_path "${KREW_ROOT:-$HOME/.krew}/bin"
