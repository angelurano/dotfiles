vim.keymap.set('n', '<Esc>', function()
  vim.cmd("nohlsearch")
  -- Close all floating windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      pcall(vim.api.nvim_win_close, win, false)
    end
  end
end, { desc = 'Clear search highlights and close floating windows' })

--[[
-- Track and toggle last active tab
local last_tab = nil
vim.api.nvim_create_autocmd("TabLeave", {
  callback = function()
    last_tab = vim.api.nvim_get_current_tabpage()
  end,
})

local function go_to_last_tab()
  if last_tab and vim.api.nvim_tabpage_is_valid(last_tab) then
    vim.api.nvim_set_current_tabpage(last_tab)
  else
    vim.notify("No previous tab to return to", vim.log.levels.WARN)
  end
end

-- Handle tabs
vim.keymap.set('n', '<leader>tx', '<cmd>tabclose<CR>', { desc = 'Close Current Neovim Tab' })
vim.keymap.set('n', '<M-h>', go_to_last_tab, { desc = 'Go to Last Active Tab' })
vim.keymap.set('n', '<M-k>', go_to_last_tab, { desc = 'Go to Last Active Tab' })
--]]

vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save file' })

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local nav = { h = "Left", j = "Down", k = "Up", l = "Right" }

    -- Write to stdout and flush immediately for atomic transmission
    local function set_user_var(key, value)
      if vim.g.vscode then return end
      -- Precomputed base64 for "true" is "dHJ1ZQ=="
      local b64_value = value == "true" and "dHJ1ZQ==" or ""
      local seq = string.format("\027]1337;SetUserVar=%s=%s\027\\", key, b64_value)
      io.stdout:write(seq)
      io.stdout:flush()
    end

    local wezterm_cmd = vim.fn.executable("wezterm.exe") == 1 and "wezterm.exe" or "wezterm"

    local function navigate(dir)
      return function()
        local win = vim.api.nvim_get_current_win()
        vim.cmd.wincmd(dir) -- Attempt navigation within Neovim

        -- If the current window remains unchanged, the edge of Neovim has been reached
        if win == vim.api.nvim_get_current_win() then
          local pane_dir = nav[dir]
          if vim.system then
            -- Call WezTerm CLI to activate the pane in the specified direction
            vim.system({ wezterm_cmd, "cli", "activate-pane-direction", pane_dir }, { text = true })
          end
        end
      end
    end

    -- Set the IS_NVIM user variable in WezTerm on startup
    set_user_var("IS_NVIM", "true")

    for key, dir in pairs(nav) do
      vim.keymap.set("n", "<C-" .. key .. ">", navigate(key), { desc = "Go to " .. dir .. " pane" })
    end

    -- Reset the IS_NVIM user variable in WezTerm on exit
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function()
        if vim.g.vscode then return end
        local seq = "\027]1337;SetUserVar=IS_NVIM=\027\\"
        io.stdout:write(seq)
        io.stdout:flush()
      end,
    })
  end,
})

-- Delete word forward in insert mode
vim.keymap.set('i', '<C-Delete>', '<C-o>dw', { desc = 'Delete word forward' })
vim.keymap.set('i', '<C-Del>', '<C-o>dw', { desc = 'Delete word forward' })
