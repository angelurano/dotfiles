vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.showmode = true
vim.o.scrolloff = 10
vim.o.ignorecase = true
vim.o.smartcase = true

if not vim.g.vscode then
  vim.o.undofile = true

  vim.o.title = true

  vim.opt.tabstop = 4
  vim.opt.shiftwidth = 4
  vim.opt.softtabstop = 4
  vim.opt.expandtab = true
  vim.opt.smartindent = true

  vim.g.have_nerd_font = true
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.breakindent = true
  vim.o.cursorline = true

  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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
