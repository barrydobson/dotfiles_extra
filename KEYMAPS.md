# Neovim Keymap Reference

This configuration is [LazyVim](https://www.lazyvim.org/) with a small number of
additions. Almost every keymap comes from LazyVim itself, so the authoritative
reference is upstream:

- [LazyVim default keymaps](https://www.lazyvim.org/keymaps)
- Per-extra keymaps are listed on each extra's page under
  [LazyVim extras](https://www.lazyvim.org/extras)
- In Neovim: `<leader>sk` searches all live keymaps, and pressing `<leader>`
  then waiting shows the which-key popup

Enabled extras (`packages/nvim/.config/nvim/lazyvim.json`): `ai.copilot`, `coding.mini-surround`,
`dap.core`, `editor.mini-files`, `lang.docker`, `lang.go`, `lang.helm`,
`lang.json`, `lang.markdown`, `lang.yaml`, `util.rest`.

## Key Notation

- `<leader>` = Space
- `<C-x>` = Ctrl + x, `<M-x>` = Alt/Option + x, `<S-x>` = Shift + x

## Custom keymaps

Set in `packages/nvim/.config/nvim/lua/config/keymaps.lua`:

| Keymap | Mode   | Action                |
| ------ | ------ | --------------------- |
| `jj`   | Insert | Escape to normal mode |
| `jk`   | Insert | Escape to normal mode |

## Copilot suggestions

Configured in `lua/plugins/copilot.lua`. Inline suggestions auto-trigger,
including in markdown and help files.

| Keymap | Action                     |
| ------ | -------------------------- |
| `<M-]>`| Next suggestion            |
| `<M-[>`| Previous suggestion        |

Accepting a suggestion is left to the completion engine (blink.cmp), not
copilot.lua, so `<Tab>` behaves as it does for any other completion item.

## Git conflicts

`git-conflict.nvim` is loaded with its default mappings (`lua/plugins/git.lua`).
Active only in a buffer containing conflict markers:

| Keymap | Action                    |
| ------ | ------------------------- |
| `co`   | Choose ours               |
| `ct`   | Choose theirs             |
| `cb`   | Choose both               |
| `c0`   | Choose none               |
| `]x`   | Next conflict             |
| `[x`   | Previous conflict         |

Gitsigns (LazyVim default) provides the `<leader>gh` hunk keymaps.

## Where to change things

| File                       | Contains                                      |
| -------------------------- | --------------------------------------------- |
| `lua/config/keymaps.lua`   | Custom keymaps                                |
| `lua/config/options.lua`   | Options (currently just `wrap`)                |
| `lua/plugins/copilot.lua`  | Copilot suggestion keys and filetypes         |
| `lua/plugins/conform.lua`  | Formatter overrides (yamlfmt for YAML)        |
| `lua/plugins/git.lua`      | git-conflict.nvim                             |
| `lua/plugins/colorschemes.lua` | Colourscheme (`catppuccin-mocha`)         |
| `lazyvim.json`             | Enabled LazyVim extras                        |
