local o = vim.opt
vim.g.mapleader = ' '          -- space is the leader key
o.expandtab = true             -- spaces, not tabs
o.shiftwidth = 2               -- 2 spaces per indent level
o.number = true                -- absolute number on the cursor line
o.relativenumber = true        -- relative line numbers for fast jumps
o.signcolumn = 'yes'           -- always show sign column so diagnostics don't shift text
o.ignorecase = true            -- search is case-insensitive by default
o.smartcase = true             -- case-sensitive only when typing a capital
o.clipboard = 'unnamedplus'    -- share the system clipboard
o.scrolloff = 16               -- keep cursor away from the screen edge
o.undofile = true              -- persistent undo across sessions
o.autowrite = true             -- save on :make, :next, buffer switch, etc.

-- Reload files changed on disk (e.g. by an agent) without leaving the buffer.
-- autoread only fires on checktime; poll it plus the usual focus/enter events.
o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  command = "if mode() !~# '[ct]' && getcmdwintype() == '' | checktime | endif",
})
vim.uv.new_timer():start(1000, 1000, vim.schedule_wrap(function()
  if not vim.fn.mode():match('[ct]') and vim.fn.getcmdwintype() == '' then vim.cmd('checktime') end
end))
