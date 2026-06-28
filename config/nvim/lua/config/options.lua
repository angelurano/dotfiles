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

  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

end

-- VSCode-specific default keybindings reference:
-- - mi: Insert multiple cursors at the start of selected lines.
-- - ma: Insert multiple cursors at the end of selected lines.
-- - gh / <S-k>: View documentation on hover (press <S-k> twice to focus the documentation window).
-- - =: Format the selected code block.
-- - gd: Go to definition (or show references if already at the definition).
-- - gt: Navigate to the next open file.
-- - g<S-t>: Navigate to the previous open file.
-- - <C-b>: Toggle the sidebar.
-- - <C-h>: Move focus to the sidebar.
-- - <C-S-e>: Open and focus the file explorer in the sidebar.
-- - Sidebar actions (when focused):
--   - j/k/l/h: Navigate.
--   - o: Open file or folder.
--   - d: Delete.
--   - x: Cut.
--   - y: Copy.
--   - p: Paste copied/cut file.
--   - r: Rename.
--   - a: Create new file.
--   - A: Create new folder.
--   - v: Open file in vertical split.
--   - h: Open file in horizontal split.
