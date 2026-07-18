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

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

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
