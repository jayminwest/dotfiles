local o = vim.opt_local
o.wrap = true         -- soft-wrap long lines...
o.linebreak = true    -- ...at word boundaries
o.spell = true        -- ]s [s next/prev typo, z= fix, zg add word

-- toggle a "- [ ]" / "- [x]" checkbox on the current line
vim.keymap.set('n', '<leader>x', function()
  local line = vim.api.nvim_get_current_line()
  local new = line:gsub('%[ %]', '[x]', 1)
  if new == line then new = line:gsub('%[x%]', '[ ]', 1) end
  vim.api.nvim_set_current_line(new)
end, { buffer = true, desc = 'Toggle Checkbox' })
