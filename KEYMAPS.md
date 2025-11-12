# 🎯 Neovim Keymap Reference

This document provides a comprehensive guide to all custom keymaps in this Neovim configuration, organized by functionality and optimized for AI-powered coding workflows.

## 🗝️ Key Notation

- `<leader>` = Space key (by default)
- `<C-x>` = Ctrl + x
- `<A-x>` = Alt + x
- `<S-x>` = Shift + x
- `[X]` in descriptions indicates the key letter for mnemonic memory

---

## 🤖 AI Workflow Hub (`<leader>a`)

**Primary interface for CodeCompanion AI features - optimized for Anthropic services**

| Keymap       | Action                | Description                                                   |
| ------------ | --------------------- | ------------------------------------------------------------- |
| `<leader>aa` | CodeCompanion Actions | **[A]I [A]ctions menu** - Main AI interface                   |
| `<leader>ac` | Chat Toggle           | **[A]I [C]hat toggle** - Open/close AI chat                   |
| `<leader>ae` | Explain Code          | **[A]I [E]xplain code** - Explain selected code (visual mode) |
| `<leader>ai` | Improve Code          | **[A]I [I]mprove code** - Get AI suggestions for improvement  |
| `<leader>ad` | Generate Docs         | **[A]I [D]ocumentation** - Generate documentation             |
| `<leader>at` | Generate Tests        | **[A]I [T]ests generate** - Create unit tests                 |
| `<leader>af` | Add to Context        | **[A]I [F]iles add to context** - Add files to AI context     |
| `<leader>ar` | Reset Context         | **[A]I [R]eset context** - Clear AI chat context              |

> 💡 **Pro Tip**: Start with `<leader>aa` to see all available AI actions

---

## 🔧 Code Operations (`<leader>c`)

**Core development tasks - LSP, formatting, and code manipulation**

| Keymap       | Action        | Description                                                   |
| ------------ | ------------- | ------------------------------------------------------------- |
| `<leader>ca` | Code Actions  | **[C]ode [A]ctions** - LSP code actions menu                  |
| `<leader>cf` | Format Code   | **[C]ode [F]ormat** - Format current buffer                   |
| `<leader>cr` | Rename Symbol | **[C]ode [R]ename** - LSP rename symbol                       |
| `<leader>ce` | Show Error    | **[C]ode [E]rror float** - Show diagnostic in floating window |
| `<leader>cq` | Quickfix List | **[C]ode [Q]uickfix list** - Open diagnostics in quickfix     |

### LSP Navigation (No Prefix)

| Keymap  | Action               | Description                         |
| ------- | -------------------- | ----------------------------------- |
| `gd`    | Go to Definition     | Jump to symbol definition           |
| `gD`    | Go to Declaration    | Jump to symbol declaration          |
| `gr`    | Go to References     | Find all references (via Telescope) |
| `gi`    | Go to Implementation | Jump to implementation              |
| `K`     | Hover Documentation  | Show documentation popup            |
| `<C-k>` | Signature Help       | Show function signature             |
| `[d`    | Previous Diagnostic  | Jump to previous diagnostic         |
| `]d`    | Next Diagnostic      | Jump to next diagnostic             |

---

## 🔍 Search & Navigation (`<leader>s`)

**Telescope-powered fuzzy finding and navigation**

### File & Content Search

| Keymap             | Action            | Description                                         |
| ------------------ | ----------------- | --------------------------------------------------- |
| `<C-p>`            | Quick File Search | Fast file finder (no prefix needed)                 |
| `<leader><leader>` | Recent Files      | **[S]earch [R]ecent files** - Recently opened files |
| `<leader>sf`       | Search Files      | **[S]earch [F]iles** - Find files by name           |
| `<leader>sg`       | Live Grep         | **[S]earch [G]rep** - Search file contents          |
| `<leader>sh`       | Help Tags         | **[S]earch [H]elp** - Search Neovim help            |
| `<leader>sk`       | Keymaps           | **[S]earch [K]eymaps** - Find keymaps               |
| `<leader>sb`       | Builtins          | **[S]earch [B]uiltins** - Telescope commands        |

### Code Navigation

| Keymap       | Action            | Description                                         |
| ------------ | ----------------- | --------------------------------------------------- |
| `<leader>ss` | Document Symbols  | **[S]earch [S]ymbols** - Symbols in current file    |
| `<leader>sS` | Workspace Symbols | **[S]earch [S]ymbols** - Symbols in workspace       |
| `<leader>sr` | References        | **[S]earch [R]eferences** - Find symbol references  |
| `<leader>sd` | Diagnostics       | **[S]earch [D]iagnostics** - Browse all diagnostics |
| `<leader>sn` | Neovim Config     | **[S]earch [N]eovim config** - Edit config files    |

---

## 🪟 Window Management (`<leader>w`)

**Split, navigate, and manage windows**

| Keymap       | Action           | Description                                          |
| ------------ | ---------------- | ---------------------------------------------------- |
| `<leader>wh` | Horizontal Split | **[W]indow [H]orizontal split** - Split horizontally |
| `<leader>wv` | Vertical Split   | **[W]indow [V]ertical split** - Split vertically     |
| `<leader>wc` | Close Window     | **[W]indow [C]lose** - Close current window          |
| `<leader>wo` | Only Window      | **[W]indow [O]nly** - Close all other windows        |

### Window Navigation (No Prefix)

| Keymap  | Action     | Description              |
| ------- | ---------- | ------------------------ |
| `<C-h>` | Move Left  | Navigate to left window  |
| `<C-j>` | Move Down  | Navigate to window below |
| `<C-k>` | Move Up    | Navigate to window above |
| `<C-l>` | Move Right | Navigate to right window |

---

## 📦 Buffer Management (`<leader>b`)

**Handle open files and buffers**

| Keymap       | Action            | Description                                         |
| ------------ | ----------------- | --------------------------------------------------- |
| `<leader>x`  | Delete Buffer     | **[B]uffer [D]elete** - Alternative close buffer    |
| `<leader>bn` | Next Buffer       | **[B]uffer [N]ext** - Switch to next buffer         |
| `<leader>bp` | Previous Buffer   | **[B]uffer [P]revious** - Switch to previous buffer |
| `<leader>ba` | Close All Buffers | **[B]uffer close [A]ll** - Close all buffers        |

---

## 🦀 Rust Development (`<leader>R`)

**Rust-specific tools and crate management**

| Keymap       | Action        | Description                                            |
| ------------ | ------------- | ------------------------------------------------------ |
| `<leader>Rt` | Toggle Crates | **[R]ust crates [T]oggle** - Show/hide crate info      |
| `<leader>Rr` | Reload Crates | **[R]ust crates [R]eload** - Refresh crate data        |
| `<leader>Ru` | Update Crate  | **[R]ust crates [U]pdate** - Update single crate       |
| `<leader>RU` | Upgrade Crate | **[R]ust crates [U]pgrade** - Upgrade to newer version |
| `<leader>RA` | Upgrade All   | **[R]ust crates upgrade [A]ll** - Upgrade all crates   |

### Crate Information

| Keymap       | Action            | Description                                        |
| ------------ | ----------------- | -------------------------------------------------- |
| `<leader>Rv` | Show Versions     | **[R]ust crates [V]ersions** - Available versions  |
| `<leader>Rf` | Show Features     | **[R]ust crates [F]eatures** - Available features  |
| `<leader>Rd` | Show Dependencies | **[R]ust crates [D]ependencies** - Dependency tree |

### Crate Links

| Keymap       | Action        | Description                                        |
| ------------ | ------------- | -------------------------------------------------- |
| `<leader>RH` | Homepage      | **[R]ust crates [H]omepage** - Open crate homepage |
| `<leader>RR` | Repository    | **[R]ust crates [R]epository** - Open source repo  |
| `<leader>RD` | Documentation | **[R]ust crates [D]ocs** - Open docs.rs            |
| `<leader>RC` | Crates.io     | **[R]ust [C]rates.io** - Open crates.io page       |
| `<leader>RL` | Lib.rs        | **[R]ust [L]ib.rs** - Open lib.rs page             |

---

## ⚙️ Configuration (`<leader>r`)

**Manage Neovim configuration**

| Keymap       | Action        | Description                                  |
| ------------ | ------------- | -------------------------------------------- |
| `<leader>rr` | Reload Config | **[R]eload [R]config** - Reload current file |

---

## 🔧 Text Manipulation

### Line Movement

| Keymap                | Action         | Description                         |
| --------------------- | -------------- | ----------------------------------- |
| `<A-k>` or `<A-Up>`   | Move Line Up   | Move current line or selection up   |
| `<A-j>` or `<A-Down>` | Move Line Down | Move current line or selection down |

### Copy & Clear

| Keymap  | Action              | Description                                      |
| ------- | ------------------- | ------------------------------------------------ |
| `<C-s>` | Save File           | **[S]ave file** - Quick save                     |
| `<C-c>` | Copy Word/Selection | Copy current word (normal) or selection (visual) |
| `<Esc>` | Clear Search        | Clear search highlight                           |

---

## 📁 File Management

### Oil.nvim File Explorer

| Keymap | Action                | Description              |
| ------ | --------------------- | ------------------------ |
| `-`    | Open Parent Directory | Navigate up in file tree |

---

## 📝 Code Folding

### Fold Operations

| Keymap  | Action        | Description                  |
| ------- | ------------- | ---------------------------- |
| `<Tab>` | Toggle Fold   | Open/close fold under cursor |
| `zj`    | Next Fold     | Jump to next fold            |
| `zk`    | Previous Fold | Jump to previous fold        |
| `zh`    | Close Fold    | Close fold under cursor      |
| `zl`    | Open Fold     | Open fold under cursor       |

### Fold Levels

| Keymap | Action         | Description                     |
| ------ | -------------- | ------------------------------- |
| `z0`   | Open All Folds | Set fold level to 99 (show all) |
| `z1`   | Fold Level 0   | Show only top-level folds       |
| `z2`   | Fold Level 1   | Show first-level folds          |
| `z3`   | Fold Level 2   | Show second-level folds         |
| `z4`   | Fold Level 3   | Show third-level folds          |
| `z5`   | Fold Level 4   | Show fourth-level folds         |

---

## 🖥️ Terminal & Git

### Terminal Management

| Keymap       | Action   | Description                                                  |
| ------------ | -------- | ------------------------------------------------------------ |
| `<leader>g`  | LazyGit  | **[G]it lazygit toggle** - Open LazyGit in floating terminal |
| `<leader>tt` | Terminal | **[T]erminal [T]oggle** - Open floating terminal             |

---

## 📋 Markdown (File-Specific)

### Checkbox Management

| Keymap    | Action          | Description                                       |
| --------- | --------------- | ------------------------------------------------- |
| `<Enter>` | Toggle Checkbox | Toggle markdown checkbox and add/remove timestamp |

> **Note**: Only active in markdown files

---

## 🚀 Quick Start Guide

### Most Important Keymaps to Remember

1. **AI Workflow**: `<leader>aa` → Start here for all AI features
2. **File Search**: `<C-p>` → Quick file finder
3. **Live Search**: `<leader>sg` → Search inside files
4. **Code Actions**: `<leader>ca` → LSP actions menu
5. **Format Code**: `<leader>cf` → Auto-format current file
6. **Help**: `<leader>?` → Show which-key popup for any prefix

### Learning the System

- **Mnemonic Memory**: Use the bracketed letters `[X]` in descriptions
- **Which-Key**: Press `<leader>` and wait to see available options
- **Prefixes**: Each category has a consistent prefix (`a`=AI, `s`=Search, `c`=Code, etc.)

---

## 🔧 Customization

To modify these keymaps:

- **Main keymaps**: Edit `lua/keymaps.lua`
- **AI keymaps**: Edit `lua/plugins/ai.lua`
- **Search keymaps**: Edit `lua/plugins/telescope.lua`
- **LSP keymaps**: Edit `lua/plugins/lsp.lua`
- **Rust keymaps**: Edit `lua/plugins/rust.lua`

> 💡 **Tip**: Use `<leader>sn` to quickly search and edit config files!
