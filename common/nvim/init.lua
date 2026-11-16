if vim.env.VSCODE then
  vim.g.vscode = true
end

if vim.loader then
  vim.loader.enable()
end

require('config.options')
require('config.keymaps')
require('config.autocmds')
if not vim.g.vscode then
  require('config.better_comments').setup()
end

if not vim.g.vscode then
  if vim.fn.has('win32') == 1 then
    if not vim.env.SSH_TTY and not vim.env.SSH_CONNECTION then
      vim.g.termfeatures = { osc52 = false }
    end

    local direct_win32yank = vim.fn.expand('~/scoop/apps/win32yank/current/win32yank.exe')
    local exe = (vim.uv or vim.loop).fs_stat(direct_win32yank) and direct_win32yank or 'win32yank.exe'
    vim.g.clipboard = {
      name = 'win32yank-direct',
      copy = {
        ['+'] = { exe, '-i', '--crlf' },
        ['*'] = { exe, '-i', '--crlf' },
      },
      paste = {
        ['+'] = { exe, '-o', '--lf' },
        ['*'] = { exe, '-o', '--lf' },
      },
      cache_enabled = 1,
    }
  end

  vim.api.nvim_create_autocmd('User', {
    pattern = 'VeryLazy',
    once = true,
    callback = function()
      vim.opt.clipboard = 'unnamedplus'
    end,
  })
end

-- [[ Install `lazy.nvim` plugin manager ]]
--    See https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  ui = {
    border = 'rounded',
  },
  defaults = {
    cond = function(plugin)
      if vim.g.vscode then
        return plugin.vscode == true
      end
      return true
    end,
  },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
