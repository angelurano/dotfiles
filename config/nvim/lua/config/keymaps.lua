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

-- Change panel size dynamically with Alt+h/j/k/l (absolute-directional)
local function resize(dir)
  return function()
    local current_win = vim.api.nvim_get_current_win()
    local current_winnr = vim.fn.winnr()

    -- Helper: lock all windows except the two involved, forcing them to winfixwidth/winfixheight = false
    local function lock_all_except(w1, w2, prop)
      local saved = {}
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        saved[w] = vim.api.nvim_get_option_value(prop, { scope = "local", win = w })
        if w ~= w1 and w ~= w2 then
          vim.api.nvim_set_option_value(prop, true, { scope = "local", win = w })
        else
          vim.api.nvim_set_option_value(prop, false, { scope = "local", win = w })
        end
      end
      return saved
    end

    local function restore_all(saved, prop)
      for w, orig in pairs(saved) do
        if vim.api.nvim_win_is_valid(w) then
          vim.api.nvim_set_option_value(prop, orig, { scope = "local", win = w })
        end
      end
    end

    if dir == "h" or dir == "l" or dir == "S-h" or dir == "S-l" then
      local left_winnr = vim.fn.winnr('h')
      local right_winnr = vim.fn.winnr('l')
      local has_left = left_winnr ~= current_winnr
      local has_right = right_winnr ~= current_winnr

      local left_win = has_left and vim.fn.win_getid(left_winnr) or nil
      local right_win = has_right and vim.fn.win_getid(right_winnr) or nil

      -- 1. Decide which boundary window to target
      local target_win = nil
      local is_left_boundary = false

      if dir == "h" or dir == "S-l" then
        if left_win and vim.api.nvim_win_is_valid(left_win) then
          target_win = left_win
          is_left_boundary = true
        elseif right_win and vim.api.nvim_win_is_valid(right_win) then
          target_win = right_win
          is_left_boundary = false
        end
      elseif dir == "l" or dir == "S-h" then
        if right_win and vim.api.nvim_win_is_valid(right_win) then
          target_win = right_win
          is_left_boundary = false
        elseif left_win and vim.api.nvim_win_is_valid(left_win) then
          target_win = left_win
          is_left_boundary = true
        end
      end

      -- 2. Apply absolute directional resize
      if target_win then
        local is_left_dir = (dir == "h" or dir == "S-h")
        local should_shrink = (is_left_dir == is_left_boundary)

        -- Save all widths before attempting lock-all
        local all_widths = {}
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          all_widths[w] = vim.api.nvim_win_get_width(w)
        end

        local before_cw = all_widths[current_win]
        local saved = lock_all_except(current_win, target_win, "winfixwidth")

        local tw = vim.api.nvim_win_get_width(target_win)
        if should_shrink then
          vim.api.nvim_win_set_width(target_win, math.max(1, tw - 2))
        else
          vim.api.nvim_win_set_width(target_win, tw + 2)
        end

        restore_all(saved, "winfixwidth")

        -- If lock-all failed (current_win didn't change), undo damage and retry directly
        local after_cw = vim.api.nvim_win_get_width(current_win)
        if after_cw == before_cw then
          -- Restore all widths to undo collateral damage from failed lock-all
          for w, width in pairs(all_widths) do
            if vim.api.nvim_win_is_valid(w) then
              pcall(vim.api.nvim_win_set_width, w, width)
            end
          end
          -- Retry: directly resize current_win (Neovim distributes proportionally)
          if should_shrink then
            vim.api.nvim_win_set_width(current_win, before_cw + 2)
          else
            vim.api.nvim_win_set_width(current_win, math.max(1, before_cw - 2))
          end
        end
      end
    elseif dir == "j" or dir == "k" or dir == "S-j" or dir == "S-k" then
      local up_winnr = vim.fn.winnr('k')
      local down_winnr = vim.fn.winnr('j')
      local has_up = up_winnr ~= current_winnr
      local has_down = down_winnr ~= current_winnr

      local up_win = has_up and vim.fn.win_getid(up_winnr) or nil
      local down_win = has_down and vim.fn.win_getid(down_winnr) or nil

      local function is_term(win)
        if not win or not vim.api.nvim_win_is_valid(win) then return false end
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        local bt = vim.bo[buf].buftype
        return ft == "terminal" or bt == "terminal"
      end

      if is_term(current_win) then
        local target_vwin = up_win or down_win
        if target_vwin then
          local all_heights = {}
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            all_heights[w] = vim.api.nvim_win_get_height(w)
          end
          local before_ch = all_heights[current_win]
          local saved = lock_all_except(current_win, target_vwin, "winfixheight")

          local h = vim.api.nvim_win_get_height(current_win)
          if dir == "k" then
            vim.api.nvim_win_set_height(current_win, h + 1)
          else
            vim.api.nvim_win_set_height(current_win, math.max(1, h - 1))
          end

          restore_all(saved, "winfixheight")

          local after_ch = vim.api.nvim_win_get_height(current_win)
          if after_ch == before_ch then
            for w, height in pairs(all_heights) do
              if vim.api.nvim_win_is_valid(w) then
                pcall(vim.api.nvim_win_set_height, w, height)
              end
            end
            if dir == "k" then
              vim.api.nvim_win_set_height(current_win, before_ch + 1)
            else
              vim.api.nvim_win_set_height(current_win, math.max(1, before_ch - 1))
            end
          end
        else
          local h = vim.api.nvim_win_get_height(current_win)
          if dir == "k" then
            vim.api.nvim_win_set_height(current_win, h + 1)
          else
            vim.api.nvim_win_set_height(current_win, math.max(1, h - 1))
          end
        end
      else
        -- Focused in code window.
        local target_win = nil
        local is_top_boundary = false

        if dir == "k" or dir == "S-j" then
          if up_win and vim.api.nvim_win_is_valid(up_win) then
            target_win = up_win
            is_top_boundary = true
          elseif down_win and vim.api.nvim_win_is_valid(down_win) then
            target_win = down_win
            is_top_boundary = false
          end
        elseif dir == "j" or dir == "S-k" then
          if down_win and vim.api.nvim_win_is_valid(down_win) then
            target_win = down_win
            is_top_boundary = false
          elseif up_win and vim.api.nvim_win_is_valid(up_win) then
            target_win = up_win
            is_top_boundary = true
          end
        end

        if target_win then
          local is_up_dir = (dir == "k" or dir == "S-k")
          local should_shrink = (is_up_dir == is_top_boundary)

          local all_heights = {}
          for _, w in ipairs(vim.api.nvim_list_wins()) do
            all_heights[w] = vim.api.nvim_win_get_height(w)
          end
          local before_ch = all_heights[current_win]
          local saved = lock_all_except(current_win, target_win, "winfixheight")

          local h = vim.api.nvim_win_get_height(target_win)
          if should_shrink then
            vim.api.nvim_win_set_height(target_win, math.max(1, h - 1))
          else
            vim.api.nvim_win_set_height(target_win, h + 1)
          end

          restore_all(saved, "winfixheight")

          local after_ch = vim.api.nvim_win_get_height(current_win)
          if after_ch == before_ch then
            for w, height in pairs(all_heights) do
              if vim.api.nvim_win_is_valid(w) then
                pcall(vim.api.nvim_win_set_height, w, height)
              end
            end
            if should_shrink then
              vim.api.nvim_win_set_height(current_win, before_ch + 2)
            else
              vim.api.nvim_win_set_height(current_win, math.max(1, before_ch - 2))
            end
          end
        end
      end
    end
  end
end

vim.keymap.set({ 'n', 't' }, '<M-h>', resize('h'), { desc = 'Resize panel left (grow)' })
vim.keymap.set({ 'n', 't' }, '<M-l>', resize('l'), { desc = 'Resize panel right (grow)' })
vim.keymap.set({ 'n', 't' }, '<M-j>', resize('j'), { desc = 'Resize panel down (grow)' })
vim.keymap.set({ 'n', 't' }, '<M-k>', resize('k'), { desc = 'Resize panel up (grow)' })

vim.keymap.set({ 'n', 't' }, '<M-S-h>', resize('S-h'), { desc = 'Resize panel shrink from left' })
vim.keymap.set({ 'n', 't' }, '<M-S-l>', resize('S-l'), { desc = 'Resize panel shrink from right' })
vim.keymap.set({ 'n', 't' }, '<M-S-j>', resize('S-j'), { desc = 'Resize panel shrink from bottom' })
vim.keymap.set({ 'n', 't' }, '<M-S-k>', resize('S-k'), { desc = 'Resize panel shrink from top' })

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
      vim.keymap.set({ "n", "t" }, "<C-" .. key .. ">", navigate(key), { desc = "Go to " .. dir .. " pane" })
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

-- Enter normal mode in terminal buffers (e.g. Snacks.terminal) to copy/navigate text
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Enter Normal Mode' })

-- Copy visual selection to system clipboard, unwrapping line breaks (great for terminal wrapping)
local function get_visual_selection()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'v' or mode == 'V' or mode == '\22' then
    vim.cmd('normal! \27')
  end
  local start_line, start_col = unpack(vim.fn.getpos("'<"), 2, 3)
  local end_line, end_col = unpack(vim.fn.getpos("'>"), 2, 3)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then return {} end
  if mode == 'v' then
    if #lines == 1 then
      lines[1] = string.sub(lines[1], start_col, end_col)
    else
      lines[1] = string.sub(lines[1], start_col)
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
  end
  return lines
end

vim.keymap.set('v', '<leader>y', function()
  local lines = get_visual_selection()
  if #lines == 0 then return end
  local cleaned = {}
  for _, line in ipairs(lines) do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed == "" then
      table.insert(cleaned, "")
    else
      table.insert(cleaned, trimmed)
    end
  end
  local result = ""
  for i, line in ipairs(cleaned) do
    if i == 1 then
      result = line
    else
      local prev = cleaned[i - 1]
      if line == "" or prev == "" then
        result = result .. "\n" .. line
      else
        result = result .. " " .. line
      end
    end
  end
  vim.fn.setreg("+", result)
  -- Trigger highlight on yank (runs TextYankPost autocmds)
  pcall(vim.api.nvim_exec_autocmds, "TextYankPost", {
    data = { regname = "+", regtype = "v" }
  })
  -- Print standard Neovim yank message in the cmdline
  if #lines > 1 then
    vim.api.nvim_echo({ { string.format("%d lines yanked", #lines), "Normal" } }, false, {})
  end
end, { desc = "Copy and unwrap visual selection to clipboard" })
