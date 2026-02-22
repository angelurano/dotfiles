vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.showmode = true
vim.o.scrolloff = 10

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.o.ignorecase = true
vim.o.smartcase = true

if not vim.g.vscode then
  vim.o.undofile = true

  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.expandtab = true
  vim.opt.smartindent = true

  vim.g.have_nerd_font = true
  vim.o.number = true
  vim.o.relativenumber = true

  vim.o.breakindent = true

  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.o.cursorline = true
end

-- in vscode, there are default shortcuts:
--   select multiple lines, and mi must inset multiple cursors at the start
--   select multiple lines, and ma must inset multiple cursors at the end of the selection
--   on hover code, can see the documentation of function, types, etc, with gh, or <shift>k
--     on do again <shift>k must use vim cursor on documentation
--   select code, and then can apply format of vscode with =
--   on hover code, can go to code declaration with gd, and when it's in definition, can
--     do gd to see the places the reference are presented, or g<shift>H
--   for go to next open file, can use gt, it's like <ctrl><tab>
--   for go to previous open file, can use g<shift>t, it's like <ctrl><shift><tab>
--   <ctrl>b open sidebar, <ctrl>h put the focus in the sidebar, <ctrl><shift>e open and focus sidebar
--   in sidebar, can move with jklh, open folder or file with o, delete with d, cut with x, copy with y, and prev p to paste copy or cut file, rename with r, add a file with a, add a folder with <shift>a
--   in sidebar, can open the file in split, vertical with v, horizontal with h

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

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  {
    -- theme
    "ribru17/bamboo.nvim",
    priority = 1000,
    lazy = false,
    vscode = false,
    config = function()
      require("bamboo").setup { }
      require("bamboo").load()
    end
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
      })
    end,
  },
  {
    "NMAC427/guess-indent.nvim",
    vscode = false,
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
    vscode = false,
  },
  {
    'willothy/wezterm.nvim',
    config = true,
    vscode = false
  }
})

