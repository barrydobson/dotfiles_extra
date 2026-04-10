# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a **stow-based dotfiles repository** managing cross-platform configurations for macOS, Linux, and Windows/WSL2. Each application's configuration lives in its own `packages/` subdirectory and is deployed using GNU Stow.

### Package Structure

```
packages/
├── <app-name>/
│   └── .config/             # Stows to ~/.config/
│       └── <app-name>/
│   └── .<filename>          # Stows to ~/.<filename>
```

**Key principle**: Packages use real dotfile names. Stow is invoked with `-t "${HOME}"` so the directory structure mirrors home directly. For example:
- `packages/zsh/.zshenv` → `~/.zshenv`
- `packages/nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

### Major Components

- **Shell**: Zsh with Zinit plugin management and Starship prompt
- **Editor**: Neovim (LazyVim-based) with CodeCompanion AI integration
- **Terminal**: Ghostty and Warp configs with Catppuccin Mocha theme
- **Git**: Modular config with Delta diffs and extensive aliases from GitAlias.com
- **Tools**: Modern CLI replacements (eza, bat, fd, ripgrep, delta, zoxide, atuin, mise)
- **Claude**: Config and skills at `packages/claude/.claude/`
- **Other**: 1Password, k9s, sketchybar, tmux, starship, ssh, vscode

## Common Development Commands

### Deployment

```bash
./install.sh           # Bootstrap: detect OS, stow configs, install tools
```

For manually stowing specific packages:

```bash
cd packages && stow -v -t "${HOME}" git zsh   # Stow specific packages
stow -v -D -t "${HOME}" git                   # Unstow a package
stow -v -R -t "${HOME}" git                   # Restow (unstow + stow)
```

### Linting

```bash
shellcheck install/*.sh   # Lint install scripts
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

- `packages/git/.config/git/config` - Main config with conditional includes
- `.gitconfig-local` - Machine-specific overrides (gitignored)
- `.gitconfig-private` - Personal/work context switching (gitignored)

When modifying git config, preserve the conditional include structure.

### Neovim Configuration

Built on LazyVim with custom plugins in `packages/nvim/.config/nvim/`:

- `init.lua` - Entry point
- `lazy-lock.json` - Plugin versions (commit this)
- Key AI features via CodeCompanion (Anthropic Claude integration)

See `KEYMAPS.md` for complete keymap reference.

### Zsh Configuration

Shell setup in `packages/zsh/.config/zsh/`:

- `conf.d/` - Numbered config files loaded in order (environment, tools, etc.)
- `aliases/` - Per-topic alias files (git, docker, modern-tools, etc.)
- `functions/` - Shell functions including `w` (worktree manager)
- `.zprofile` - Environment setup
- `.zshenv` at `packages/zsh/.zshenv` - Sets `ZDOTDIR`

Aliases map traditional tools to modern alternatives (e.g., `ls` → `eza`, `cat` → `bat`).

### LazyGit Integration

LazyGit has **AI-powered commit message generation** via Claude Code:

- Press `C` in LazyGit to generate contextual commit messages
- Analyzes staged changes to create meaningful descriptions

## Important Patterns

### When Adding New Packages

1. Create `packages/<app-name>/` directory
2. Add configs using real dotfile names (`.config/<app>/` for XDG, `.<filename>` for home-dir dotfiles)
3. Add installation commands to appropriate `install/*.sh` script
4. Stow the new package: `cd packages && stow -v -t "${HOME}" <app-name>`
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

1. **Test deployment**: `cd packages && stow -v -R -t "${HOME}" <package>`
2. **Verify symlinks**: Check that files appear in correct locations (`ls -la ~/.<config>`)
3. **Test functionality**: Open relevant application and verify config loads
4. **Check for conflicts**: Stow will error if files already exist without symlinks

## Architecture Decisions

### Why Stow?

GNU Stow provides:

- Clean separation of configs per tool
- Easy deployment/rollback via symlinks
- No custom scripts needed for symlinking logic

### Why Packages Structure?

Each tool is self-contained, making it easy to:

- Add/remove tools independently
- Share configs between machines selectively
- Understand what files belong to which tool
- Maintain tool-specific documentation
