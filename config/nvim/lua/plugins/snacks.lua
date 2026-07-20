local terminals = {} -- stores terminal_id -> buffer_id
local last_term_height = nil
local last_win_layout = nil
local last_sidekick_width = nil
local toggle_terminal, toggle_floating_terminal

local function get_terminal_wins()
  local term_wins = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) then
      local config = vim.api.nvim_win_get_config(w)
      if config.relative == "" then
        local b = vim.api.nvim_win_get_buf(w)
        if vim.api.nvim_buf_is_valid(b) then
          local ft = vim.bo[b].filetype
          local bt = vim.bo[b].buftype
          if (bt == "terminal" or ft == "terminal") and ft ~= "sidekick" and ft ~= "sidekick_terminal" then
            table.insert(term_wins, w)
          end
        end
      end
    end
  end
  return term_wins
end

local function list_terminals()
  local items = {}
  for count, buf in pairs(terminals) do
    if vim.api.nvim_buf_is_valid(buf) then
      local is_open = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then
          is_open = true
          break
        end
      end
      local label = (count == 99) and "Flotante" or tostring(count)
      local status = is_open and "󰄬 Visible" or "󰈉 Oculta"
      table.insert(items, {
        text = string.format("Terminal %s [%s]", label, status),
        count = count,
        buf = buf,
      })
    end
  end

  table.sort(items, function(a, b) return a.count < b.count end)

  if #items == 0 then
    vim.notify("No hay terminales activas", vim.log.levels.INFO, { title = "Terminales" })
    return
  end

  require("snacks").picker({
    title = " Terminales Activas (<c-d> / dd: Cerrar) ",
    items = items,
    focus = "list",
    format = function(item)
      return { { item.text } }
    end,
    win = {
      preview = {
        focusable = false,
      },
      input = {
        keys = {
          ["<c-d>"] = { "kill_term", mode = { "n", "i" } },
          ["dd"] = { "kill_term", mode = { "n" } },
        },
      },
    },
    actions = {
      kill_term = function(picker, item)
        if item then
          local buf = item.buf
          local count = item.count
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
          if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
          end
          terminals[count] = nil
          picker:close()
          vim.schedule(function()
            list_terminals()
          end)
        end
      end,
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        vim.schedule(function()
          if item.count == 99 then
            toggle_floating_terminal()
          else
            toggle_terminal(item.count)
          end
        end)
      end
    end,
  })
end

function toggle_floating_terminal()
  require("snacks").terminal.toggle(nil, {
    win = {
      position = "float",
      border = "rounded",
      height = 0.8,
      width = 0.8,
      title = " Terminal ",
      title_pos = "center",
      keys = {
        ["<Esc><Esc>"] = { function() vim.cmd("stopinsert") end, mode = "t" },
        ["<C-h>"] = { "hide", mode = { "t", "n" } },
        ["<C-j>"] = { "hide", mode = { "t", "n" } },
        ["<C-k>"] = { "hide", mode = { "t", "n" } },
        ["<C-l>"] = { "hide", mode = { "t", "n" } },
      },
    },
    count = 99,
  })
end

function toggle_terminal(target_count)
  local snacks = require("snacks")
  local explicit_count = (target_count ~= nil) or (vim.v.count > 0)
  local count = target_count or vim.v.count1
  local has_sidekick, sidekick_cli = pcall(require, "sidekick.cli")

  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local ft = vim.bo[current_buf].filetype

  -- 1. Check if currently inside any terminal window (excluding Sidekick)
  local is_term_buf = (vim.bo[current_buf].buftype == "terminal" or ft == "terminal")
      and ft ~= "sidekick"
      and ft ~= "sidekick_terminal"
      and vim.b[current_buf].sidekick_cli == nil

  if is_term_buf then
    local is_floating = vim.api.nvim_win_get_config(current_win).relative ~= ""

    if is_floating then
      toggle_floating_terminal()
      if not explicit_count or count == 99 then
        return
      end
    else
      -- Currently inside a split terminal window
      local current_term_count = nil
      for c, b in pairs(terminals) do
        if b == current_buf then
          current_term_count = c
          break
        end
      end

      -- If no explicit count was typed, OR user typed the SAME count as current terminal:
      -- Toggle off (close current split terminal window)
      if not explicit_count or (current_term_count and current_term_count == count) then
        local h = vim.api.nvim_win_get_height(current_win)
        last_term_height = h
        vim.api.nvim_win_close(current_win, true)
        for _, w in ipairs(get_terminal_wins()) do
          if vim.api.nvim_win_is_valid(w) then
            vim.api.nvim_win_set_height(w, h)
          end
        end
        return
      end

      -- User typed a DIFFERENT count (e.g., 2<leader>t while inside terminal 1)
      local target_buf = terminals[count]
      local target_win = nil
      if target_buf and vim.api.nvim_buf_is_valid(target_buf) then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_buf(win) == target_buf then
            target_win = win
            break
          end
        end
      end

      if target_win then
        -- Target terminal is already open elsewhere: focus it, then close current window
        vim.api.nvim_set_current_win(target_win)
        vim.cmd("startinsert")
        vim.api.nvim_win_close(current_win, true)
        return
      else
        -- Target terminal is not open: REUSE current_win! Zero flicker, zero re-rendering!
        if target_buf and vim.api.nvim_buf_is_valid(target_buf) then
          vim.api.nvim_win_set_buf(current_win, target_buf)
        else
          vim.api.nvim_win_call(current_win, function()
            vim.cmd("terminal")
          end)
          target_buf = vim.api.nvim_win_get_buf(current_win)
          terminals[count] = target_buf
          vim.bo[target_buf].filetype = "terminal"
        end
        vim.wo[current_win].winbar = " " .. count .. ": term "
        vim.cmd("startinsert")
        return
      end
    end
  end

  -- Save layout and lock code window heights to prevent shifts
  local locked_wins = {}
  local open_term_wins = get_terminal_wins()
  local any_term_open = (#open_term_wins > 0)

  if any_term_open then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local win_ft = vim.bo[buf].filetype
      local win_bt = vim.bo[buf].buftype
      if win_bt ~= "terminal" and win_ft ~= "terminal" and win_ft ~= "sidekick" and win_ft ~= "sidekick_terminal" then
        locked_wins[win] = vim.wo[win].winfixheight
        vim.wo[win].winfixheight = true
      end
    end
  else
    last_win_layout = vim.fn.winrestcmd()
  end

  -- Find if terminal #count is currently open in any window
  local term_buf = terminals[count]
  local term_win = nil

  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_buf then
        term_win = win
        break
      end
    end
  end

  if term_win then
    if not explicit_count or current_win == term_win then
      -- Target terminal #count is open and either no count was specified or it's the current window: close it (toggle off)
      local h = vim.api.nvim_win_get_height(term_win)
      last_term_height = h
      vim.api.nvim_win_close(term_win, true)
      for _, w in ipairs(get_terminal_wins()) do
        if vim.api.nvim_win_is_valid(w) then
          vim.api.nvim_win_set_height(w, h)
        end
      end
      for w, orig in pairs(locked_wins) do
        if vim.api.nvim_win_is_valid(w) then
          vim.wo[w].winfixheight = orig
        end
      end
      return
    else
      -- Target terminal #count is open elsewhere and user specified an explicit count: focus it!
      vim.api.nvim_set_current_win(term_win)
      vim.cmd("startinsert")
      for w, orig in pairs(locked_wins) do
        if vim.api.nvim_win_is_valid(w) then
          vim.wo[w].winfixheight = orig
        end
      end
      return
    end
  else
    -- Terminal is closed, we want to open it.
    -- If there is already an open terminal window, inherit its current height
    local current_terms = get_terminal_wins()
    if #current_terms > 0 then
      last_term_height = vim.api.nvim_win_get_height(current_terms[1])
    end

    -- 1. Check if Snacks Explorer is open
    local explorer = snacks.picker.get({ source = "explorer" })[1]
    local reopen_explorer = false
    if explorer then
      reopen_explorer = true
      explorer:close()
    end

    -- 2. Check if Sidekick is open (bulletproof detection matching filetype, name, or terminal metadata)
    local reopen_sidekick = false
    if has_sidekick then
      local sidekick_win = nil
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local wft = vim.bo[buf].filetype
        local name = vim.api.nvim_buf_get_name(buf)
        if wft == "sidekick" or wft == "sidekick_terminal" or string.match(name, "sidekick") or vim.b[buf].sidekick_cli ~= nil then
          sidekick_win = win
          break
        end
      end
      if sidekick_win then
        reopen_sidekick = true
        last_sidekick_width = vim.api.nvim_win_get_width(sidekick_win)
        pcall(function()
          sidekick_cli.hide()
        end)
      end
    end

    -- Schedule opening the terminal and reopening sidebars to let Neovim complete window closures
    vim.schedule(function()
      -- 3. Find all open terminal windows and their counts, sorted left to right
      local open_terms = {}
      for _, win in ipairs(get_terminal_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local win_count = nil
        for c, b in pairs(terminals) do
          if b == buf then
            win_count = c
            break
          end
        end
        if win_count then
          table.insert(open_terms, { win = win, count = win_count, x = vim.api.nvim_win_get_position(win)[2] })
        end
      end
      table.sort(open_terms, function(a, b) return a.x < b.x end)

      -- 4. Create split for terminal in the correct relative position
      local new_win
      if #open_terms > 0 then
        local target_win = nil
        local cmd = nil

        if count < open_terms[1].count then
          target_win = open_terms[1].win
          cmd = "leftabove vertical split"
        elseif count > open_terms[#open_terms].count then
          target_win = open_terms[#open_terms].win
          cmd = "rightbelow vertical split"
        else
          for i = 1, #open_terms - 1 do
            if count > open_terms[i].count and count < open_terms[i + 1].count then
              target_win = open_terms[i].win
              cmd = "rightbelow vertical split"
              break
            end
          end
          if not target_win then
            target_win = open_terms[#open_terms].win
            cmd = "rightbelow vertical split"
          end
        end

        vim.api.nvim_set_current_win(target_win)
        vim.cmd(cmd)
        new_win = vim.api.nvim_get_current_win()
      else
        -- No existing terminal window, open a new bottom split
        vim.cmd("botright split")
        new_win = vim.api.nvim_get_current_win()
        local h = last_term_height or math.floor(vim.o.lines * 0.3)
        vim.api.nvim_win_set_height(new_win, h)
        vim.wo[new_win].winfixheight = true
      end

      -- Configure terminal window options
      vim.w[new_win].is_terminal_win = true
      vim.wo[new_win].number = false
      vim.wo[new_win].relativenumber = false
      vim.wo[new_win].signcolumn = "no"
      vim.wo[new_win].winfixheight = true

      if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        -- Reuse existing terminal buffer
        vim.api.nvim_win_set_buf(new_win, term_buf)
      else
        -- Create terminal process in the window and set filetype
        vim.api.nvim_win_call(new_win, function()
          vim.cmd("terminal")
        end)
        term_buf = vim.api.nvim_win_get_buf(new_win)
        terminals[count] = term_buf
        vim.bo[term_buf].filetype = "terminal"
      end

      -- Set winbar after the buffer is set to avoid Neovim resetting it
      vim.wo[new_win].winbar = " " .. count .. ": term "

      -- 5. Reopen Snacks Explorer if needed
      if reopen_explorer then
        snacks.explorer()
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "snacks_layout_box" then
              vim.api.nvim_win_call(win, function()
                vim.cmd("wincmd H")
              end)
              break
            end
          end
        end)
      end

      -- 6. Reopen Sidekick if needed (FileType/BufWinEnter autocmd in autocmds.lua will position it, and we force it here as well)
      if reopen_sidekick and has_sidekick then
        pcall(function()
          sidekick_cli.show()
        end)
        -- Scheduled fallback to force Sidekick to the far right and restore its width
        vim.schedule(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local wft = vim.bo[buf].filetype
            if wft == "sidekick" or wft == "sidekick_terminal" or vim.b[buf].sidekick_cli ~= nil then
              vim.api.nvim_win_call(win, function()
                vim.cmd("wincmd L")
                local width = last_sidekick_width or 45
                if not last_sidekick_width then
                  pcall(function()
                    width = require("sidekick.config").cli.win.split.width or 45
                  end)
                end
                vim.api.nvim_win_set_width(win, width)
              end)
              break
            end
          end
        end)
      end

      -- 7. Focus back to terminal window
      if vim.api.nvim_win_is_valid(new_win) then
        vim.api.nvim_set_current_win(new_win)
        vim.cmd("startinsert")
      end

      -- Enforce the saved height on all terminal windows before restoring equalalways
      local h = last_term_height or math.floor(vim.o.lines * 0.3)
      for _, w in ipairs(get_terminal_wins()) do
        if vim.api.nvim_win_is_valid(w) then
          vim.api.nvim_win_set_height(w, h)
        end
      end

      -- Restore original winfixheight settings on code windows
      for w, orig in pairs(locked_wins) do
        if vim.api.nvim_win_is_valid(w) then
          vim.wo[w].winfixheight = orig
        end
      end
    end)
  end
end

-- Force winbar to display "count: term" for terminal windows (overriding dropbar or default layout modifications)
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("terminal-winbar", { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    if vim.bo[buf].buftype == "terminal" then
      local win = vim.api.nvim_get_current_win()
      vim.w[win].is_terminal_win = true
      local winbar_text = nil
      for count, tbuf in pairs(terminals) do
        if tbuf == buf then
          winbar_text = " " .. count .. ": term "
          break
        end
      end
      if winbar_text then
        vim.wo[win].winbar = winbar_text
      end
    end
  end,
})

-- Equalize terminal widths whenever window layouts change to prevent any terminal from being squished to size 1
local function equalize_terminal_widths()
  local term_wins = get_terminal_wins()
  if #term_wins <= 1 then return end

  -- Sort left-to-right
  table.sort(term_wins, function(a, b)
    return vim.api.nvim_win_get_position(a)[2] < vim.api.nvim_win_get_position(b)[2]
  end)

  local total_w = 0
  local widths = {}
  for _, w in ipairs(term_wins) do
    local w_val = vim.api.nvim_win_get_width(w)
    total_w = total_w + w_val
    table.insert(widths, w_val)
  end

  local base_w = math.floor(total_w / #term_wins)
  local extra = total_w % #term_wins

  local already_equal = true
  for i, w_val in ipairs(widths) do
    local target_w = base_w + (i <= extra and 1 or 0)
    if w_val ~= target_w then
      already_equal = false
      break
    end
  end

  if already_equal then return end

  -- Temporarily lock other windows to prevent Neovim from stealing width from code windows
  local saved_locks = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local is_term_win = false
    for _, tw in ipairs(term_wins) do
      if tw == w then
        is_term_win = true
        break
      end
    end
    if not is_term_win and vim.api.nvim_win_get_config(w).relative == "" then
      saved_locks[w] = vim.api.nvim_get_option_value("winfixwidth", { scope = "local", win = w })
      vim.api.nvim_set_option_value("winfixwidth", true, { scope = "local", win = w })
    end
  end

  for i, w in ipairs(term_wins) do
    local target_w = base_w + (i <= extra and 1 or 0)
    vim.api.nvim_win_set_width(w, target_w)
  end

  -- Restore original winfixwidth values
  for w, orig in pairs(saved_locks) do
    if vim.api.nvim_win_is_valid(w) then
      vim.api.nvim_set_option_value("winfixwidth", orig, { scope = "local", win = w })
    end
  end
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWinLeave", "WinClosed", "WinNew", "VimResized" }, {
  group = vim.api.nvim_create_augroup("terminal-equalize-widths", { clear = true }),
  callback = function()
    vim.schedule(equalize_terminal_widths)
  end,
})

-- Save terminal window height when it leaves or closes, so we remember it
vim.api.nvim_create_autocmd("BufWinLeave", {
  group = vim.api.nvim_create_augroup("terminal-save-height", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if not vim.api.nvim_buf_is_valid(buf) then return end
    local ft = vim.bo[buf].filetype
    local bt = vim.bo[buf].buftype
    if (bt == "terminal" or ft == "terminal") and ft ~= "sidekick" and ft ~= "sidekick_terminal" then
      local win = vim.fn.bufwinid(buf)
      if win ~= -1 and vim.api.nvim_win_is_valid(win) then
        local config = vim.api.nvim_win_get_config(win)
        if config.relative == "" then
          last_term_height = vim.api.nvim_win_get_height(win)
        end
      end

      -- If all terminal windows are closed, restore the layout
      vim.schedule(function()
        if #get_terminal_wins() == 0 and last_win_layout then
          pcall(function() vim.cmd(last_win_layout) end)
        end
      end)
    end
  end,
})

return {
  {
    "folke/snacks.nvim",
    priority = 1000, -- Early load to ensure scroll and indent work on startup
    lazy = false,
    opts = {
      -- Notifier
      notifier = {
        enabled = true,
        timeout = 3000,
        top_down = false,
        margin = { top = 0, right = 1, bottom = 1 },
      },

      -- Indent guides
      indent = {
        enabled = true,
      },

      -- Native image renderer (disabled in WSL due to terminal bridge rendering limits)
      image = { enabled = vim.fn.has("wsl") == 0 },

      -- Native Git components

      git = { enabled = true },

      -- Explorer layout customization
      picker = {
        actions = {
          git_add = function(picker)
            local selected = picker:selected({ fallback = true })
            if #selected == 0 then return end
            for _, item in ipairs(selected) do
              if item.file then
                local path = vim.fn.shellescape(item.file)
                -- Check if file has staged changes (exit status 1 if staged)
                vim.fn.system("git diff --cached --quiet -- " .. path)
                local is_staged = vim.v.shell_error ~= 0
                if is_staged then
                  vim.fn.system("git reset HEAD -- " .. path)
                else
                  vim.fn.system("git add " .. path)
                end
              end
            end
            picker:action("explorer_update")
          end,
          git_commit = function(picker)
            vim.ui.input({ prompt = "Commit message: " }, function(input)
              if input and input ~= "" then
                local out = vim.fn.system("git commit -m " .. vim.fn.shellescape(input))
                vim.notify(out, vim.log.levels.INFO, { title = "Git Commit" })
                picker:action("explorer_update")
              end
            end)
          end,
        },
        win = {
          input = {
            keys = {
              ["J"] = { "preview_scroll_down", mode = { "i", "n" } },
              ["K"] = { "preview_scroll_up", mode = { "i", "n" } },
            },
          },
        },
        sources = {
          git_status = { focus = "list" },
          git_branches = { focus = "list" },
          git_log = { focus = "list" },
          git_log_line = { focus = "list" },
          git_stash = { focus = "list" },
          gh_pr = { focus = "list" },
          gh_issue = { focus = "list" },
          explorer = {
            hidden = true,
            jump = { close = true },
            win = {
              input = {
                keys = {
                  ["<C-x>"] = { "edit_split", mode = { "i", "n" } },
                  ["<C-h>"] = { "close", mode = { "i", "n" } },
                  ["<C-j>"] = { "close", mode = { "i", "n" } },
                  ["<C-k>"] = { "close", mode = { "i", "n" } },
                  ["ga"] = { "git_add", mode = { "i", "n" } },
                  ["gc"] = { "git_commit", mode = { "i", "n" } },
                },
              },
              list = {
                keys = {
                  ["<C-x>"] = { "edit_split", mode = { "i", "n" } },
                  ["<C-h>"] = { "close", mode = { "i", "n" } },
                  ["<C-j>"] = { "close", mode = { "i", "n" } },
                  ["<C-k>"] = { "close", mode = { "i", "n" } },
                  ["ga"] = { "git_add", mode = { "i", "n" } },
                  ["gc"] = { "git_commit", mode = { "i", "n" } },
                },
              },
            },
            layout = {
              preset = "sidebar",
              preview = nil,
              layout = {
                position = "left",
                width = 30,
                min_width = 30,
              },
            },
          },
        },
      },

      styles = {
        notification = {
          wo = { wrap = true }
        }
      },

      words = { enabled = true },
      scope = { enabled = true },
      terminal = {
        auto_insert = false,
        win = {
          position = "bottom",
          relative = "editor",
          height = 0.33,
        },
      },

      -- Smooth scroll animation (disabled for instant, lag-free movement)
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[ ]],
          keys = {
            { icon = "󰋚 ", key = "y", desc = "Yazi File Manager", action = ":Yazi" },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('recent')" },
            { icon = " ", key = "c", desc = "Config", action = ":e $MYVIMRC" },
            { icon = " ", key = "s", desc = "Restore Last Session", action = ":lua require('persistence').load()" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy" },
            { icon = "󰚩 ", key = "p", desc = "Lazy Profile", action = ":Lazy profile" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "startup" },
          { section = "header" },
          { section = "keys",   gap = 1, padding = 1 },
        },
      },
    },
    keys = {
      -- Explorer keymaps
      { "<leader>e",         function() Snacks.explorer() end,              desc = "File Explorer" },
      { "<C-S-e>",           function() Snacks.explorer() end,              desc = "File Explorer" },

      -- Git keymaps
      { "<leader>gb",        function() Snacks.picker.git_branches() end,   desc = "Git Branches" },
      { "<leader>gB",        function() Snacks.git.blame_line() end,        desc = "Git Blame Line" },
      { "<leader>go",        function() Snacks.gitbrowse() end,             desc = "Git Browse",               mode = { "n", "v" } },
      { "<leader>gl",        function() Snacks.picker.git_log() end,        desc = "Git Log" },
      { "<leader>gL",        function() Snacks.picker.git_log_line() end,   desc = "Git Log Line" },
      { "<leader>gs",        function() Snacks.picker.git_status() end,     desc = "Git Status" },
      { "<leader>gS",        function() Snacks.picker.git_stash() end,      desc = "Git Stash" },

      -- GitHub keymaps
      { "<leader>gp",        function() Snacks.picker.gh_pr() end,          desc = "GitHub PRs" },
      { "<leader>gi",        function() Snacks.picker.gh_issue() end,       desc = "GitHub Issues" },

      -- Terminal keymaps
      { "<leader>t",         toggle_terminal,                               desc = "Toggle Terminal" },
      { "<C-\\>",            toggle_terminal,                               desc = "Toggle Terminal",          mode = { "n", "t" } },
      { "<leader><leader>t", toggle_floating_terminal,                      desc = "Toggle Floating Terminal", mode = "n" },
      { "0<leader>t",        toggle_floating_terminal,                      desc = "Toggle Floating Terminal", mode = { "n" } },
      { "<leader>ft",        list_terminals,                                desc = "Find Active Terminals" },

      -- Notifier keymaps
      { "<leader>nh",        function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>nd",        function() Snacks.notifier.hide() end,         desc = "Dismiss All Notifications" },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Prevent equalize from running when relative is "win" to avoid resizing sidebars/other columns
      local win = require("snacks.win")
      ---@diagnostic disable-next-line: invisible
      local orig_equalize = win.equalize
      ---@diagnostic disable-next-line: invisible
      win.equalize = function(self)
        if self.opts.relative == "win" then
          return
        end
        ---@diagnostic disable-next-line: param-type-mismatch
        return orig_equalize(self)
      end
    end,
  }
}
