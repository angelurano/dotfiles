vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.showmode = false
vim.o.scrolloff = 10
vim.o.ignorecase = true
vim.o.smartcase = true

if not vim.g.vscode then
  vim.o.undofile = true

  vim.o.title = true

  -- powershell/pwsh as default shell on Windows
  if vim.fn.has("win32") == 1 then
    local powershell_info = {
      shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
      shellcmdflag =
      "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
      shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
      shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
      shellquote = "",
      shellxquote = "",
    }

    for option, value in pairs(powershell_info) do
      vim.opt[option] = value
    end
  end

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
