# Personal Dotfiles

A comprehensive, cross-platform dotfiles configuration for macOS, Windows, and Linux environments. This configuration emphasizes modern tooling, consistent theming, and AI-assisted developer productivity.

## 🤖 AI-Powered Development Features

This dotfiles setup includes integrated AI assistance for enhanced development workflows:

- **🧠 Neovim AI Assistant**: Built-in CodeCompanion plugin supporting multiple AI providers:
  - **Anthropic Claude** (default): Industry-leading code generation and analysis

- **📝 AI-Generated Git Commits**: LazyGit integration with Claude Code:
  - Press `C` in LazyGit to auto-generate contextual commit messages
  - Analyzes staged changes to create meaningful commit descriptions
  - Generates both summary line and detailed commit body
  - Streamlines git workflow with intelligent commit message suggestions

**📖 See [CLAUDE.md](CLAUDE.md) for detailed Claude Code integration setup**

## Features

- **Cross-Platform Support**: Works on macOS, Windows (WSL2), and Linux
- **Modern CLI Tools**: Replaces traditional tools with faster, feature-rich alternatives
- **Consistent Theming**: Catppuccin Mocha theme across all applications
- **Modern Editor**: Neovim configuration with Lazy.nvim and AI integration
- **Git Workflow**: Enhanced git experience with delta diffs and lazygit UI
- **Shell Enhancement**: Zsh with modern completions and smart directory navigation

## Quick Start

### Prerequisites

- **OS**: macOS 10.15+, Ubuntu 20.04+, Arch Linux, or Windows 10+ with WSL2
- **Git**: For cloning the repository
- **Stow**: Installed automatically if missing
- **macOS**: Xcode Command Line Tools (`xcode-select --install`)
- **Linux**: Build essentials (`build-essential` on Ubuntu, `base-devel` on Arch)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/barrydobson/dotfiles-public.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install system-specific tools:**

   ```bash
   # macOS
   ./install/macos.sh

   # Ubuntu/Debian Linux
   ./install/ubuntu.sh

   # Arch Linux
   ./install/arch-linux.sh
   ```

3. **Deploy dotfiles:**

   ```bash
   make stow
   ```

4. **Verify installation:**

   ```bash
   make check
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
- **Prompt**: Powerlevel10k with custom configuration
- **Completions**: Modern tab completion system
- **Aliases**: Shortcuts for modern CLI tools

### Terminal Emulators

Configurations provided for:

- **Alacritty**: GPU-accelerated terminal
- **Ghostty**: Fast, feature-rich terminal

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
- **Git integration**: Gitsigns, conflict resolution, and Lazygit integration
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
# Management
make stow          # Deploy dotfiles
make unstow        # Remove dotfiles
make restow        # Redeploy dotfiles
make backup        # Create timestamped backup
make restore       # Restore from latest backup

# Development
make lint          # Run shellcheck on scripts
make test          # Run tests (when implemented)
```

### Git Integration

- Use `lazygit` for terminal-based git UI
- Delta provides enhanced diff viewing
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

1. Add installation commands to appropriate install script
2. Create configuration file in `src/`
3. Update README with tool information

### Theme Customization

All applications use Catppuccin Mocha. To change:

1. Update theme references in configs
2. Rebuild bat cache: `bat cache --build`

### Local Overrides

- Git: Use `.gitconfig-local` for machine-specific settings
- Environment: Use `.env` for local environment variables
- Shell: Add local customizations to `.zshrc.local`

## Troubleshooting

### Common Issues

**Stow conflicts:**

```bash
make unstow    # Remove existing links
make clean     # Clean up broken links
make stow      # Redeploy
```

**Font not displaying:**

- Ensure Nerd Fonts are installed
- Rebuild font cache: `fc-cache -f` (Linux)
- Restart terminal application

**Shell completions missing:**

- Reload shell: `exec zsh`
- Check plugin installation in `~/.zinit`

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
