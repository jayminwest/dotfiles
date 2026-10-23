-- nvim-lspconfig only ships server configs (lsp/*.lua); nvim itself runs them.
-- Servers are installed by home.nix. Built-in keys once attached:
--   gd def (snacks)  K hover  grr refs  grn rename  gra action  gO symbols
--   [d ]d prev/next diagnostic  <C-s> signature help (insert)
return {
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    config = function()
      vim.diagnostic.config({ virtual_text = true })
      vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, { autotrigger = true })
        end,
      })
      vim.lsp.enable({ 'rust_analyzer', 'ts_ls', 'marksman' })
    end,
    keys = {
      { '<leader>S', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Search Symbols' },
      { '<leader>d', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>R', function() Snacks.picker.lsp_references() end, desc = 'References' },
    },
  },
}
