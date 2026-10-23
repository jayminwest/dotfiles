-- System-wide light/dark theme, driven by the shared mode file that WezTerm and
-- yazi also read. dark -> kanagawa, light -> everforest (light background).
-- We poll the file so nvim switches live when `theme` / Ctrl+Shift+T is used,
-- even while nvim is the focused window.
local M = {}

local uv = vim.uv or vim.loop
local mode_file = vim.fn.expand('~/.config/theme-mode')
local current

local function read_mode()
  local f = io.open(mode_file, 'r')
  if not f then
    return 'dark'
  end
  local m = (f:read('l') or ''):gsub('%s+', '')
  f:close()
  return m == 'light' and 'light' or 'dark'
end

function M.apply()
  local mode = read_mode()
  if mode == current then
    return
  end
  current = mode
  if mode == 'light' then
    vim.o.background = 'light'
    pcall(vim.cmd.colorscheme, 'everforest')
  else
    vim.o.background = 'dark'
    pcall(vim.cmd.colorscheme, 'kanagawa')
  end
end

function M.setup()
  -- Ensure the shared file exists (default dark) so the poller has a target.
  if not uv.fs_stat(mode_file) then
    local f = io.open(mode_file, 'w')
    if f then
      f:write('dark\n')
      f:close()
    end
  end

  M.apply()

  local poll = uv.new_fs_poll()
  if poll then
    poll:start(mode_file, 1000, vim.schedule_wrap(M.apply))
  end
end

return M
