-- Git integration plugins for version control workflows
-- Provides git signs in the gutter and conflict resolution tools
return {
  {
    -- Shows git changes in the sign column with inline blame and hunk navigation
    'lewis6991/gitsigns.nvim',
    config = true
  },
  {
    -- Enhanced git conflict resolution with visual markers and commands
    'akinsho/git-conflict.nvim',
    config = true
  }
}