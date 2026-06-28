vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local nav = { h = "Left", j = "Down", k = "Up", l = "Right" }

    -- Base64 encoding required by the WezTerm user variable protocol
    local function base64(data)
      data = tostring(data)
      local bit = require("bit")
      local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
      local b64, len = "", #data
      for i = 1, len, 3 do
        local a, b, c = data:byte(i, i + 2)
        local buffer = bit.bor(bit.lshift(a, 16), bit.lshift(b or 0, 8), c or 0)
        for j = 0, 3 do
          local index = bit.rshift(buffer, (3 - j) * 6) % 64
          b64 = b64 .. b64chars:sub(index + 1, index + 1)
        end
      end
      local padding = (3 - len % 3) % 3
      b64 = b64:sub(1, -1 - padding) .. ("="):rep(padding)
      return b64
    end

    -- Write to stdout and flush immediately for atomic transmission
    local function set_user_var(key, value)
      if vim.g.vscode then return end
      local seq = string.format("\027]1337;SetUserVar=%s=%s\027\\", key, base64(value))
      io.stdout:write(seq)
      io.stdout:flush()
    end

    local wezterm_cmd = "wezterm.exe"

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

