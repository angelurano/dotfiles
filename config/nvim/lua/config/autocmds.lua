vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('CursorHold', {
  desc = 'Show diagnostics in a floating window on hover',
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Disable automatic comment insertion on enter or o/O",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})
