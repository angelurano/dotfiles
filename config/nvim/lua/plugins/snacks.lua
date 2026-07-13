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
                },
              },
              list = {
                keys = {
                  ["<C-x>"] = { "edit_split", mode = { "i", "n" } },
                  ["<C-h>"] = { "close", mode = { "i", "n" } },
                  ["<C-j>"] = { "close", mode = { "i", "n" } },
                  ["<C-k>"] = { "close", mode = { "i", "n" } },
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
          relative = "win",
        },
      },

      -- Smooth scroll animation (disabled for instant, lag-free movement)
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[ ]],
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
      { "<leader>gd", function() Snacks.picker.git_diff() end,     desc = "Git Diff (Hunks)" },

      -- GitHub keymaps
      { "<leader>gp", function() Snacks.picker.gh_pr() end,        desc = "GitHub PRs" },
      { "<leader>gi", function() Snacks.picker.gh_issue() end,     desc = "GitHub Issues" },

      -- Terminal
      { "<leader>t",  function() Snacks.terminal() end,            desc = "Terminal" },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Prevent equalize from running when relative is "win" to avoid resizing sidebars/other columns
      local win = require("snacks.win")
      local orig_equalize = win.equalize
      win.equalize = function(self)
        if self.opts.relative == "win" then
          return
        end
        return orig_equalize(self)
      end
    end,
  }
}
