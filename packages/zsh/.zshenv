export ZDOTDIR="${HOME}/.config/zsh"

# macOS Terminal.app writes session files into $ZDOTDIR, which is a stow
# symlink into the dotfiles repo. Set here because /etc/zshrc reads it
# before ~/.zshrc runs.
export SHELL_SESSIONS_DISABLE=1

#=============================================================================
# PATH
#=============================================================================
# Set in .zshenv, not conf.d, so non-interactive shells (zsh -c, ssh commands,
# git hooks, editor tasks) get the same PATH as an interactive one.

add_to_path() {
    local new_path="$1"
    case ":$PATH:" in
        *":$new_path:"*) ;;
        *) export PATH="$new_path:$PATH" ;;
    esac
}

add_to_path "$HOME/.local/bin"
add_to_path "/opt/nvim/bin"
add_to_path "$HOME/go/bin"
add_to_path "${KREW_ROOT:-$HOME/.krew}/bin"
add_to_path "$HOME/.bun/bin"
