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

      -- Smooth scroll animation (disabled for instant, lag-free movement)
      scroll = { enabled = false },

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

      statuscolumn = { enabled = true },

      words = { enabled = false },
      scope = { enabled = true },
      dashboard = { enabled = false },
    },
    keys = {
      -- Explorer keymaps
      { "<leader>e",  function() Snacks.explorer() end,            desc = "File Explorer" },
      { "<C-S-e>",    function() Snacks.explorer() end,            desc = "File Explorer" },

      -- Git keymaps
      { "<leader>gl", function() Snacks.picker.git_log() end,      desc = "Git Log" },
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gB", function() Snacks.git.blame_line() end,      desc = "Git Blame Line" },
      { "<leader>gs", function() Snacks.picker.git_status() end,   desc = "Git Status" },
      { "<leader>gd", function() Snacks.picker.git_diff() end,     desc = "Git Diff (Hunks)" },
      { "<leader>go", function() Snacks.gitbrowse() end,           desc = "Open Git URL in Browser" },

      -- GitHub keymaps
      { "<leader>gp", function() Snacks.picker.gh_pr() end,        desc = "GitHub PRs" },
      { "<leader>gi", function() Snacks.picker.gh_issue() end,     desc = "GitHub Issues" },
    },
    config = function(_, opts)
      require("snacks").setup(opts)
    end,
  }
}
