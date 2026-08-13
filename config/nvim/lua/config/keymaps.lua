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
vim.keymap.set('n', '<leader><Tab>', '<C-^>', { desc = 'Toggle alternate buffer' })

-- Toggle window zoom (maximizes current window in a temporary tab)
vim.keymap.set('n', '<leader>z', function()
  if vim.fn.tabpagenr('$') > 1 and vim.t.is_zoomed then
    vim.cmd('tabclose')
  else
    vim.cmd('tab split')
    vim.t.is_zoomed = true
  end
end, { desc = 'Toggle Window Zoom' })

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

    local function is_term(win)
      if not win or not vim.api.nvim_win_is_valid(win) then return false end
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      local bt = vim.bo[buf].buftype
      return ft == "terminal" or bt == "terminal"
    end

    -- Reusable save-lock-resize-restore-fallback logic
    local function perform_locked_resize(prop, current, target, step, should_shrink)
      local is_width = (prop == "winfixwidth")
      local get_size = is_width and vim.api.nvim_win_get_width or vim.api.nvim_win_get_height
      local set_size = is_width and vim.api.nvim_win_set_width or vim.api.nvim_win_set_height

      -- Save all sizes before attempting lock-all
      local all_sizes = {}
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        all_sizes[w] = get_size(w)
      end

      local before_cur = all_sizes[current]
      local saved = lock_all_except(current, target, prop)

      local target_size = get_size(target)
      if should_shrink then
        set_size(target, math.max(1, target_size - step))
      else
        set_size(target, target_size + step)
      end

      restore_all(saved, prop)

      -- If lock-all failed (current size didn't change), restore and resize current directly
      local after_cur = get_size(current)
      if after_cur == before_cur then
        for w, sz in pairs(all_sizes) do
          if vim.api.nvim_win_is_valid(w) then
            pcall(set_size, w, sz)
          end
        end
        if should_shrink then
          set_size(current, before_cur + step)
        else
          set_size(current, math.max(1, before_cur - step))
        end
      end
    end

    if dir == "h" or dir == "l" or dir == "S-h" or dir == "S-l" then
      local step = is_term(current_win) and 1 or 2
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
        perform_locked_resize("winfixwidth", current_win, target_win, step, should_shrink)
      end
    elseif dir == "j" or dir == "k" or dir == "S-j" or dir == "S-k" then
      local step = 1
      local up_winnr = vim.fn.winnr('k')
      local down_winnr = vim.fn.winnr('j')
      local has_up = up_winnr ~= current_winnr
      local has_down = down_winnr ~= current_winnr

      local up_win = has_up and vim.fn.win_getid(up_winnr) or nil
      local down_win = has_down and vim.fn.win_getid(down_winnr) or nil

      if is_term(current_win) then
        local target_vwin = up_win or down_win
        if target_vwin then
          local should_shrink = (dir == "j" or dir == "S-j")
          perform_locked_resize("winfixheight", target_vwin, current_win, step, should_shrink)
        else
          local h = vim.api.nvim_win_get_height(current_win)
          if dir == "k" then
            vim.api.nvim_win_set_height(current_win, h + step)
          else
            vim.api.nvim_win_set_height(current_win, math.max(1, h - step))
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
          perform_locked_resize("winfixheight", current_win, target_win, step, should_shrink)
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
    local wincmd = { h = "h", j = "j", k = "k", l = "l" }

    -- Write to stdout and flush immediately for atomic transmission
    local function set_user_var(key, value)
      if vim.g.vscode then return end
      -- Precomputed base64 for "true" is "dHJ1ZQ=="
      local b64_value = value == "true" and "dHJ1ZQ==" or ""
      local seq = string.format("\027]1337;SetUserVar=%s=%s\027\\", key, b64_value)
      io.stdout:write(seq)
      io.stdout:flush()
    end

    local uv = vim.uv or vim.loop
    local herdr_pane = vim.env.HERDR_PANE_ID
    local in_herdr = herdr_pane ~= nil and herdr_pane ~= ""

    local socket_path = vim.env.HERDR_SOCKET_PATH
    if not socket_path or socket_path == "" then
      socket_path = vim.fn.expand("~/.config/herdr/herdr.sock")
    end

    -- Write Neovim PID marker for Herdr's C navigation binary to read
    local marker_path = nil
    if in_herdr then
      local cache = vim.env.XDG_CACHE_HOME
      if not cache or cache == "" then
        cache = vim.env.HOME .. "/.cache"
      end
      marker_path = cache .. "/herdr/nvim-panes/" .. herdr_pane
      vim.fn.mkdir(vim.fn.fnamemodify(marker_path, ":h"), "p")
      local fd = io.open(marker_path, "w")
      if fd then
        fd:write(tostring(uv.os_getpid()), "\n")
        fd:close()
      end
    end

    local function release_marker()
      if marker_path then
        os.remove(marker_path)
      end
    end

    vim.api.nvim_create_autocmd("VimResume", {
      callback = function()
        if marker_path then
          local fd = io.open(marker_path, "w")
          if fd then
            fd:write(tostring(uv.os_getpid()), "\n")
            fd:close()
          end
        end
      end,
    })
    vim.api.nvim_create_autocmd({ "VimSuspend", "VimLeavePre" }, { callback = release_marker })

    -- Precompute JSON focus payloads for the socket
    local focus_payloads = {}
    if in_herdr then
      for key, dir in pairs(nav) do
        focus_payloads[key] = vim.json.encode({
          id = "nvim.nav",
          method = "pane.focus_direction",
          params = { direction = dir:lower(), pane_id = herdr_pane },
        }) .. "\n"
      end
    end

    local function focus_via_socket(key)
      local pipe = uv.new_pipe(false)
      if not pipe then return false end
      local reached = nil
      pipe:connect(socket_path, function(err)
        if err then
          reached = false
        else
          pipe:write(focus_payloads[key])
          reached = true
        end
      end)
      vim.wait(150, function() return reached ~= nil end, 1)
      pipe:close()
      return reached == true
    end

    local wezterm_cmd = vim.fn.executable("wezterm.exe") == 1 and "wezterm.exe" or "wezterm"

    local function navigate(key)
      return function()
        local win = vim.api.nvim_get_current_win()
        vim.cmd("wincmd " .. wincmd[key])

        if win == vim.api.nvim_get_current_win() then
          local pane_dir = nav[key]
          if in_herdr then
            if not focus_via_socket(key) then
              vim.system({ "herdr", "pane", "focus", "--direction", pane_dir:lower() }, { text = true })
            end
          else
            vim.system({ wezterm_cmd, "cli", "activate-pane-direction", pane_dir }, { text = true })
          end
        end
      end
    end

    -- Set the IS_NVIM user variable in WezTerm on startup
    set_user_var("IS_NVIM", "true")

    for key, dir in pairs(nav) do
      vim.keymap.set({ "n", "v", "t" }, "<C-" .. key .. ">", navigate(key), { desc = "Go to " .. dir .. " pane" })
    end

    -- Reset the IS_NVIM user variable in WezTerm on exit
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function()
        release_marker()
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
