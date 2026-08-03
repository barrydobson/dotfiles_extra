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

**Key principle**: Packages use real dotfile names, so the directory structure mirrors home directly. For example:
- `packages/zsh/.zshenv` → `~/.zshenv`
- `packages/nvim/.config/nvim/init.lua` → `~/.config/nvim/init.lua`

`packages/.stowrc` already sets `--target=~/` and ignores `.stowrc`, `./install`, `./.claude`. The `-t "${HOME}"` in the commands below is redundant but matches what the install scripts do.

### Major Components

- **Shell**: Zsh with Zinit plugin management and Starship prompt
- **Editor**: Neovim (LazyVim-based) with CodeCompanion AI integration; also `zed`, `vscode`
- **Terminal**: Ghostty and Warp configs with Catppuccin Mocha theme
- **Git**: Modular config with Delta diffs and extensive aliases from GitAlias.com
- **Tools**: `atuin`, `eza`, `mise`, `k9s`, `homebrew` (Brewfile), `yamllint`, `editorconfig`, `worktrunk`, `ccstatusline`
- **Claude**: Config, skills, agents and rules at `packages/claude/.claude/` - see gotcha below
- **Other**: `1Password`, `ssh`, `tmux`, `starship`, `claude-mem`, `agents`, `skills`

**Deployment source of truth**: the `COMMON_PACKAGES` / `MAC_PACKAGES` arrays in `install.sh` and `DEVCONTAINER_PACKAGES` in `install/devcontainer.sh`. A directory under `packages/` is not deployed unless it is listed there. Every directory in `packages/` is currently listed; `.github/workflows/lint.yml` fails the build if an array names a package that does not exist.

`packages/agents` must be stowed wherever `packages/claude` is - the tavily skills under `.claude/skills/` are symlinks into `~/.agents/skills/`.

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
shellcheck -x --source-path=SCRIPTDIR install.sh install/*.sh   # Same command CI runs; must exit 0
```

`.markdownlint.json` exists (MD013 off, MD007 indent 2) but no markdownlint CLI is installed; it is only honoured by editor extensions. Match those rules when writing markdown here, don't try to run it.

### Platform-Specific Installation

Called by `install.sh` after OS detection; `install/common.sh` is sourced (not executed) and provides the `print_*` output functions plus the `install_*` helpers.

```bash
./install/mac.sh          # macOS: Homebrew + GUI apps
./install/ubuntu.sh       # Ubuntu/Debian: apt + manual installs
./install/arch-linux.sh   # Arch: pacman + AUR
./install/devcontainer.sh # Devcontainer: stows a 4-package subset, see DEVCONTAINERS.md
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

- `conf.d/` - Numbered config files, glob-loaded in order by `.zshrc` (`00_platform` → `50_tools`)
- `aliases/` - Per-topic alias files (git, docker, modern-tools, etc.)
- `functions/` - Shell functions, added to `fpath` before `conf.d` loads
- `.zshenv` at `packages/zsh/.zshenv` - Sets `ZDOTDIR`

Aliases map traditional tools to modern alternatives (e.g., `ls` → `eza`, `cat` → `bat`).

Gitignored, so absent on a fresh clone: `.zprofile`, `.zsh_history`, `99_private-environment.zsh` (machine-local secrets/env - picked up automatically by the `conf.d` glob).

### Claude Configuration

**`~/.claude` is a directory symlink to `packages/claude/.claude`.** Consequences:

- Edits under `packages/claude/.claude/` take effect immediately. No stow step.
- Claude Code's live runtime state (`history.jsonl`, `projects/`, `plugins/`, `cache/`, `daemon*`) writes into the repo working tree. `packages/claude/.gitignore` excludes it - check that file before assuming a new path is committable, and never `git add -A` here without reading the diff.
- Only ~24 files are tracked: `CLAUDE.md`, `RTK.md`, `settings.json`, `rules/`, `skills/`, `agents/`, `themes/`, `scheduled-tasks/`.

`packages/claude/.claude/CLAUDE.md` is the global user instruction file, not project context. Changing it changes Claude's behaviour in every repo.

## Important Patterns

### When Adding New Packages

1. Create `packages/<app-name>/` directory
2. Add configs using real dotfile names (`.config/<app>/` for XDG, `.<filename>` for home-dir dotfiles)
3. Add the package name to the relevant array in `install.sh` (`COMMON_PACKAGES` or `MAC_PACKAGES`) - otherwise it never deploys
4. Add installation commands to appropriate `install/*.sh` script
5. Stow the new package: `cd packages && stow -v -t "${HOME}" <app-name>`
6. Document in README.md if user-facing

When **removing** a package, delete its name from the `install.sh` arrays too. Stow aborts the whole run on a missing package, and a stale symlink in `~/.config` is left dangling.

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
2. **Verify symlinks**: `ls -la ~/.config/<app>` - confirm it resolves into this repo, not dangling
3. **Test functionality**: shell changes with `exec zsh`; others by opening the application
4. **Check for conflicts**: Stow errors if a real file already exists where a symlink should go
