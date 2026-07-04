vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.showmode = true
vim.o.scrolloff = 10
vim.o.ignorecase = true
vim.o.smartcase = true

if not vim.g.vscode then
  vim.o.undofile = true

  vim.o.title = true

  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.opt.expandtab = true
  vim.opt.smartindent = true
  vim.opt.endofline = true
  vim.opt.fixendofline = true

  vim.g.have_nerd_font = true
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.breakindent = true
  vim.o.cursorline = true
  -- vim.o.laststatus = 3

  -- vim.o.list = true
  -- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
end
