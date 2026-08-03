# Personal Dotfiles

A comprehensive, cross-platform dotfiles configuration for macOS, Windows, and Linux environments. This configuration emphasizes modern tooling, consistent theming, and AI-assisted developer productivity.

## 🤖 AI-Powered Development Features

This dotfiles setup includes integrated AI assistance for enhanced development workflows:

- **🧠 Neovim AI Assistant**: Built-in CodeCompanion plugin supporting multiple AI providers:
  - **Anthropic Claude** (default): Industry-leading code generation and analysis

- **🤖 Claude Code**: Global config, skills, agents and rules in `packages/claude/.claude/`, symlinked to `~/.claude`

**📖 See [CLAUDE.md](CLAUDE.md) for detailed Claude Code integration setup**

## Features

- **Cross-Platform Support**: Works on macOS, Windows (WSL2), and Linux
- **Modern CLI Tools**: Replaces traditional tools with faster, feature-rich alternatives
- **Consistent Theming**: Catppuccin Mocha theme across all applications
- **Modern Editor**: Neovim configuration with Lazy.nvim and AI integration
- **Git Workflow**: Enhanced git experience with delta diffs and worktree tooling
- **Shell Enhancement**: Zsh with modern completions and smart directory navigation

## Quick Start

### Prerequisites

- **OS**: macOS 10.15+, Ubuntu/Debian 20.04+, or Windows 10+ with WSL2
- **Git**: For cloning the repository
- **Stow**: Installed automatically if missing
- **macOS**: Xcode Command Line Tools (`xcode-select --install`)
- **Linux**: Build essentials (`build-essential`)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/barrydobson/dotfiles-public.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Bootstrap** (detects the OS, installs tools, stows configs):

   ```bash
   ./install.sh
   ```

   To run only the platform tool installation, without stowing:

   ```bash
   ./install/mac.sh          # macOS
   ./install/ubuntu.sh       # Ubuntu/Debian
   ```

3. **Reload the shell:**

   ```bash
   exec zsh
   ```

## Key Tools and Replacements

| Traditional | Modern Alternative | Purpose |
|-------------|-------------------|---------|
| `ls` | `eza` | Directory listing with icons |
| `cat` | `bat` | Syntax highlighting and paging |
| `find` | `fd` | Fast file finder |
| `grep` | `ripgrep` | Fast text search |
| `cd` | `zoxide` | Smart directory navigation |
| `git diff` | `delta` | Enhanced git diffs |
| `top/htop` | Built-in | Process monitoring |

## Configuration Highlights

### Shell (Zsh)

- **Plugin Manager**: Zinit for fast plugin loading
- **Prompt**: Starship, configured in `packages/starship/`
- **Completions**: Modern tab completion system
- **Aliases**: Shortcuts for modern CLI tools

### Terminal Emulators

Configurations provided for:

- **Ghostty**: Fast, feature-rich terminal
- **Warp**: Themes only

All terminals use:

- **Font**: JetBrainsMono Nerd Font (consistent across platforms)
- **Theme**: Catppuccin Mocha
- **Key bindings**: Standardized shortcuts

### Text Editors

#### Neovim

Modern Neovim configuration with Lazy.nvim plugin management.

Features:

- **AI-Powered Development**: CodeCompanion integration with multiple AI providers
- **LSP integration**: Full language server support for multiple languages
- **Fuzzy finding**: Telescope with extensive search capabilities
- **Git integration**: Gitsigns and conflict resolution
- **Modern UI**: Consistent theming with Catppuccin Mocha
- **Advanced Code Intelligence**: Treesitter, autocompletion, and code folding
- **Session Management**: Use `:mksession` to create initial session files for mini.sessions

### Git Configuration

- **Modular Config**: Separate files for personal/work contexts
- **Enhanced Diffs**: Delta for syntax-highlighted diffs
- **Extensive Aliases**: GitAlias.com collection (1,749 aliases)
- **Conditional Includes**: Context-aware configuration

## Development Workflow

### Daily Commands

```bash
# Deployment (run from packages/)
cd packages
stow -v -t "${HOME}" git zsh    # Deploy specific packages
stow -v -D -t "${HOME}" git     # Remove a package
stow -v -R -t "${HOME}" git     # Redeploy a package

# Development
shellcheck install.sh install/*.sh    # Lint shell scripts
```

### Git Integration

- Delta provides enhanced diff viewing
- `wt` switches between git worktrees
- Extensive alias collection for common operations
- Context-aware configuration for work vs personal

### Shell Productivity

- `z <partial-path>` - Smart directory jumping
- `ll`, `la` - Enhanced directory listings
- `bathelp <command>` - Colorized help pages
- `fzf` integration for command history and file search

### Key Bindings and Shortcuts

- **📖 [Complete Keybinding Reference](KEYMAPS.md)** - Comprehensive guide to all keybindings
- **Neovim**: 50+ AI-enhanced keybindings for development workflow
- **Shell**: Modern CLI shortcuts and productivity commands
- **Git**: Efficient version control with extensive alias collection

## Platform-Specific Notes

### macOS

- GUI applications installed to `~/Applications`
- Homebrew manages all CLI tools and fonts

### Linux

- System package managers used for base tools
- Manual installation of newer tools from GitHub releases
- Font installation to `~/.local/share/fonts`

### Windows

- Works via WSL2 with Ubuntu configuration
- Windows Terminal configuration can be added

## Customization

### Adding New Tools

1. Create `packages/<tool>/` with the config at its real dotfile path
2. Add the package name to `COMMON_PACKAGES` or `MAC_PACKAGES` in `install.sh`
3. Add installation commands to the appropriate install script
4. Update README with tool information

### Theme Customization

All applications use Catppuccin Mocha. To change:

1. Update theme references in configs
2. Rebuild bat cache: `bat cache --build`

### Local Overrides

All gitignored:

- Git: `.gitconfig-local` for machine-specific settings, `.gitconfig-private` for work/personal context
- Shell: `packages/zsh/.config/zsh/conf.d/99_private-environment.zsh` - loaded automatically by the `conf.d` glob

## Troubleshooting

### Common Issues

**Stow conflicts:**

```bash
cd packages
stow -v -R -t "${HOME}" <package>   # Restow (unstow + stow)
```

Stow refuses to overwrite a real file. Move or delete the conflicting file, then restow.

**Font not displaying:**

- Ensure Nerd Fonts are installed
- Rebuild font cache: `fc-cache -f` (Linux)
- Restart terminal application

**Shell completions missing:**

- Reload shell: `exec zsh`
- Check plugin installation in `~/.zinit`

## Notes

- **Caveman Hooks Only**: `bash <(curl -s <https://raw.githubusercontent.com/JuliusBrussee/caveman/main/hooks/install.sh>)`

## Contributing

This is a personal dotfiles repository, but suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch
3. Test changes across platforms
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Catppuccin](https://catppuccin.com/) for the beautiful color scheme
- [GitAlias.com](https://github.com/GitAlias/gitalias) for comprehensive git aliases
- [Zinit](https://github.com/zdharma-continuum/zinit) for fast zsh plugin management
- [Clank](https://github.com/obra/clank) for claude code integration inspiration
- The open source community for modern CLI tool alternatives
