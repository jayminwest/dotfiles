return {
  {
    'stevearc/oil.nvim',
    opts = { view_options = { show_hidden = true } },
    keys = { { '<leader>e', '<cmd>Oil<cr>', desc = 'File Browser' } },
  },
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      notifier = { enabled = true },
      input = { enabled = true },
    },
    keys = {
      { '<leader>f', function() Snacks.picker.files() end, desc = 'Find Files' },
      { '<leader>F', function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = 'Find All Files (incl. ignored)' },
      { '<leader>s', function() Snacks.picker.grep() end,  desc = 'Search Text' },
      { '<leader>b', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>w', function() Snacks.picker.grep_word() end, desc = 'Search Word/Selection', mode = { 'n', 'x' } },
      { '<leader>r', function() Snacks.picker.resume({ exclude = { 'lsp_references', 'lsp_definitions' } }) end, desc = 'Resume Last Search' },
      { '<leader>o', function() Snacks.picker.recent() end, desc = 'Recent Files' },
      { '<leader>k', function() Snacks.picker.keymaps() end, desc = 'Search Keymaps' },
      { '<leader>h', function() Snacks.picker.help() end, desc = 'Search Help' },
      { 'gd', function() Snacks.picker.lsp_definitions() end, desc = 'Goto Definition' },
    },
  },
}
