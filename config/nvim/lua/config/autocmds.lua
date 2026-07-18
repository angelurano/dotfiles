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
    -- Only show diagnostics in Normal mode
    if vim.api.nvim_get_mode().mode ~= 'n' then
      return
    end

    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    if bt == "terminal" or ft == "terminal" or ft == "sidekick" or ft == "sidekick_terminal" then
      return
    end

    -- Skip if blink.cmp completion menu is visible
    local blink_ok, blink = pcall(require, "blink.cmp")
    if blink_ok and blink.is_visible() then
      return
    end

    -- Skip if any floating window showing documentation/hover is already open
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      local config = vim.api.nvim_win_get_config(win)
      if config.relative ~= "" then
        local win_buf = vim.api.nvim_win_get_buf(win)
        local win_ft = vim.bo[win_buf].filetype
        -- "markdown" is used by LSP hover and signature help.
        -- blink-cmp windows use filetypes starting with "blink" (e.g. blink-cmp-doc).
        if win_ft == "markdown" or win_ft:match("^blink%-cmp") then
          return
        end
      end
    end

    -- Only open if there are diagnostics on the current line
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local diagnostics = vim.diagnostic.get(buf, { lnum = line })
    if #diagnostics == 0 then
      return
    end

    pcall(vim.diagnostic.open_float, nil, { focusable = false })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Disable automatic comment insertion on enter or o/O",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  desc = "Reload buffer when file changes on disk",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Configure terminal buffers and disable accidental jump keys",
  group = vim.api.nvim_create_augroup("terminal-settings", { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    vim.keymap.set("n", "<C-o>", "<Nop>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-i>", "<Nop>", { buffer = true, silent = true })
    vim.keymap.set("n", "<C-^>", "<Nop>", { buffer = true, silent = true })
    vim.keymap.set("n", "<leader>q", "<cmd>close<CR>", { buffer = true, silent = true, desc = "Close Terminal Window" })
  end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Automatically position Sidekick at the far right with full height",
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "sidekick_terminal" then
      vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == ev.buf then
            vim.api.nvim_win_call(win, function()
              vim.cmd("wincmd L")
              local width = 45
              pcall(function()
                width = require("sidekick.config").cli.win.split.width or 45
              end)
              vim.api.nvim_win_set_width(win, width)
            end)
            break
          end
        end
      end)
    end
  end,
})

vim.api.nvim_create_autocmd("TermClose", {
  desc = "Automatically close terminal windows when the process exits",
  group = vim.api.nvim_create_augroup("terminal-close", { clear = true }),
  callback = function(args)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == args.buf then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end,
})
