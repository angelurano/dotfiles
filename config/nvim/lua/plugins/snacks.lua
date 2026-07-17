local terminals = {} -- stores terminal_id -> buffer_id
local last_term_height = nil
local last_win_layout = nil

local function get_terminal_wins()
  local term_wins = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(w) then
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
  return term_wins
end

local function toggle_terminal()
  local snacks = require("snacks")
  local count = vim.v.count1
  local has_sidekick, sidekick_cli = pcall(require, "sidekick.cli")

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

  -- If currently inside any terminal window (excluding Sidekick), close it immediately.
  local current_buf = vim.api.nvim_get_current_buf()
  local current_win = vim.api.nvim_get_current_win()
  local ft = vim.bo[current_buf].filetype
  if (vim.bo[current_buf].buftype == "terminal" or ft == "terminal")
      and ft ~= "sidekick"
      and ft ~= "sidekick_terminal"
      and vim.b[current_buf].sidekick_cli == nil then
    local h = vim.api.nvim_win_get_height(current_win)
    last_term_height = h

    -- Check if this is the last terminal window
    local term_wins = get_terminal_wins()
    vim.api.nvim_win_close(current_win, true)

    -- Force remaining terminal windows to keep the current height
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

    return
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
    -- Terminal is open, just close the window (hides terminal, process stays alive)
    local h = vim.api.nvim_win_get_height(term_win)
    last_term_height = h

    -- Check if this is the last terminal window
    local term_wins = get_terminal_wins()
    vim.api.nvim_win_close(term_win, true)

    -- Force remaining terminal windows to keep the current height
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

    return
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
      local sidekick_open = false
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local wft = vim.bo[buf].filetype
        local name = vim.api.nvim_buf_get_name(buf)
        if wft == "sidekick" or wft == "sidekick_terminal" or string.match(name, "sidekick") or vim.b[buf].sidekick_cli ~= nil then
          sidekick_open = true
          break
        end
      end
      if sidekick_open then
        reopen_sidekick = true
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
          vim.schedule(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local wft = vim.bo[buf].filetype
              if wft == "sidekick" or wft == "sidekick_terminal" or vim.b[buf].sidekick_cli ~= nil then
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
        end)
      end

      -- 7. Focus back to terminal window (deferred to run last after all sidebar layout changes and focuses settle)
      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(new_win) then
          vim.api.nvim_set_current_win(new_win)
          vim.cmd("startinsert")
        end

        -- Enforce the saved height on all terminal windows before restoring equalalways
        local h = last_term_height or math.floor(vim.o.lines * 0.3)
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          local b = vim.api.nvim_win_get_buf(w)
          local bft = vim.bo[b].filetype
          local bbt = vim.bo[b].buftype
          if (bbt == "terminal" or bft == "terminal") and bft ~= "sidekick" and bft ~= "sidekick_terminal" then
            if vim.api.nvim_win_is_valid(w) then
              vim.api.nvim_win_set_height(w, h)
            end
          end
        end

        -- Restore original winfixheight settings on code windows
        for w, orig in pairs(locked_wins) do
          if vim.api.nvim_win_is_valid(w) then
            vim.wo[w].winfixheight = orig
          end
        end
      end, 50)
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
    if not is_term_win then
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
        last_term_height = vim.api.nvim_win_get_height(win)
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
      { "<leader>e",  function() Snacks.explorer() end,            desc = "File Explorer" },
      { "<C-S-e>",    function() Snacks.explorer() end,            desc = "File Explorer" },

      -- Git keymaps
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gB", function() Snacks.git.blame_line() end,      desc = "Git Blame Line" },
      { "<leader>go", function() Snacks.gitbrowse() end,           desc = "Git Browse",      mode = { "n", "v" } },
      { "<leader>gl", function() Snacks.picker.git_log() end,      desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end,   desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end,    desc = "Git Stash" },

      -- GitHub keymaps
      { "<leader>gp", function() Snacks.picker.gh_pr() end,        desc = "GitHub PRs" },
      { "<leader>gi", function() Snacks.picker.gh_issue() end,     desc = "GitHub Issues" },

      -- Terminal keymaps
      { "<leader>t",  toggle_terminal,                             desc = "Toggle Terminal" },
      { "<C-\\>",     toggle_terminal,                             desc = "Toggle Terminal", mode = { "n", "t" } },
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
