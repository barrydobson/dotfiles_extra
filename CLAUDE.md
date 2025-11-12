# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a **stow-based dotfiles repository** managing cross-platform configurations for macOS, Linux, and Windows/WSL2. Each application's configuration lives in its own `packages/` subdirectory and is deployed using GNU Stow.

### Package Structure

```
packages/
├── <app-name>/
│   └── dot-config/          # Stows to ~/.config/
│       └── <app-name>/
│   └── dot-<filename>       # Stows to ~/.<filename>
```

**Key principle**: The `dot-` prefix gets converted to `.` by Stow. For example:
- `packages/zsh/dot-zshrc` → `~/.zshrc`
- `packages/nvim/dot-config/nvim/init.lua` → `~/.config/nvim/init.lua`

### Major Components

- **Shell**: Zsh with Zinit plugin management and Powerlevel10k prompt
- **Editor**: Neovim (LazyVim-based) with CodeCompanion AI integration
- **Terminal**: Alacritty and Ghostty configs with Catppuccin Mocha theme
- **Git**: Modular config with Delta diffs and extensive aliases from GitAlias.com
- **Tools**: Modern CLI replacements (eza, bat, fd, ripgrep, delta, zoxide)
- **Claude**: Skills wiki at `packages/claude/dot-claude/skills/` with development methodologies

## Common Development Commands

### Package Management

```bash
make stow              # Deploy all packages to home directory
make unstow            # Remove all package symlinks
make restow            # Redeploy (unstow + stow)
make MODULES="git zsh" stow   # Deploy only specific packages
make check             # Verify prerequisites installed
```

### Development Workflow

```bash
make lint              # Run shellcheck on install scripts
shellcheck install/*.sh packages/**/*.sh  # Lint specific scripts
```

### Platform-Specific Installation

```bash
./install/mac.sh       # macOS: Homebrew + GUI apps
./install/ubuntu.sh    # Ubuntu/Debian: apt + manual installs
./install/arch-linux.sh  # Arch: pacman + AUR
```

## Key Integration Points

### Git Configuration

Git config is **modular**:
- `packages/git/dot-config/git/config` - Main config with conditional includes
- `.gitconfig-local` - Machine-specific overrides (gitignored)
- `.gitconfig-private` - Personal/work context switching (gitignored)

When modifying git config, preserve the conditional include structure.

### Neovim Configuration

Built on LazyVim with custom plugins in `packages/nvim/dot-config/nvim/`:
- `init.lua` - Entry point
- `lazy-lock.json` - Plugin versions (commit this)
- Key AI features via CodeCompanion (Anthropic Claude integration)

See `KEYMAPS.md` for complete keymap reference.

### Zsh Configuration

Shell setup in `packages/zsh/dot-config/zsh/`:
- `.zshrc` - Main config with Zinit plugin loading
- `.aliases.zsh` - Modern CLI tool aliases
- `.zprofile` - Environment setup
- `functions/` - Shell functions

Aliases map traditional tools to modern alternatives (e.g., `ls` → `eza`, `cat` → `bat`).

### LazyGit Integration

LazyGit has **AI-powered commit message generation** via Claude Code:
- Press `C` in LazyGit to generate contextual commit messages
- Analyzes staged changes to create meaningful descriptions

## Important Patterns

### When Adding New Packages

1. Create `packages/<app-name>/` directory
2. Add configs with `dot-` prefix for dotfiles or `dot-config/` for XDG configs
3. Add installation commands to appropriate `install/*.sh` script
4. Run `make restow` to deploy
5. Document in README.md if user-facing

### When Modifying Install Scripts

- All install scripts use color-coded output functions (`print_status`, `print_success`, `print_error`, `print_warning`)
- Scripts must be idempotent (safe to run multiple times)
- Check for existing installations before attempting to install
- Use platform detection where needed

### Cross-Platform Considerations

- **macOS**: Uses Homebrew for everything, GUI apps to `~/Applications`
- **Linux**: Mix of system package managers and manual GitHub releases
- **Fonts**: JetBrainsMono Nerd Font is required; installed differently per platform
- **Theme**: Catppuccin Mocha is standard across all tools

## Testing Changes

Before committing changes to configs:

1. **Test deployment**: `make restow` (or `make MODULES="<package>"` restow for specific packages)
2. **Verify symlinks**: Check that files appear in correct locations (`ls -la ~/.<config>`)
3. **Test functionality**: Open relevant application and verify config loads
4. **Check for conflicts**: Stow will error if files already exist without symlinks

## Architecture Decisions

### Why Stow?

GNU Stow provides:
- Clean separation of configs per tool
- Easy deployment/rollback via symlinks
- Selective package management via `MODULES` variable
- No custom scripts needed for symlinking logic

### Why Packages Structure?

Each tool is self-contained, making it easy to:
- Add/remove tools independently
- Share configs between machines selectively
- Understand what files belong to which tool
- Maintain tool-specific documentation

### Why dot- Prefix?

Stow doesn't create dotfiles by default. The `dot-` prefix naming convention:
- Makes dotfiles visible in the repo (no hidden files)
- Automatically converts to `.` when stowing
- Standard pattern in dotfiles repos
