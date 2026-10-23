-- Both colorschemes are installed and loaded eagerly; which one is active is
-- decided by lua/theme.lua from the shared ~/.config/theme-mode file.
return {
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.everforest_background = 'medium'
      vim.g.everforest_better_performance = 1
    end,
  },
}
