-- save by pressing Escape (only in real, named, modified file buffers;
-- special buffers like neogit/help/quickfix reject :w with E382)
vim.keymap.set('n', '<Esc>', function()
  if vim.bo.buftype == '' and vim.bo.modifiable
      and vim.api.nvim_buf_get_name(0) ~= '' and vim.bo.modified then
    vim.cmd.write()
  end
end, { desc = 'Save' })
-- select all
vim.keymap.set('n', '<C-a>', 'ggVG', { desc = 'Select All' })
-- pasting over a selection no longer clobbers the clipboard
vim.cmd([[ xnoremap <expr> p 'pgv"'.v:register.'y' ]])
