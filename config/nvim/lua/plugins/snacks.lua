return {
  {
    "folke/snacks.nvim",
    priority = 1000, -- Early load to ensure scroll and indent work on startup
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- Integrated File Explorer
      explorer = { enabled = true },

      -- Indent guides
      indent = {
        enabled = true,
        char = "│",
        blank = " ",
        animate = {
          enabled = false, -- Disable animation
        },
      },

      -- Smooth scroll animation
      scroll = { enabled = true },

      -- Native image renderer
      image = { enabled = true },

      -- Native Git components
      git = { enabled = true },

      -- GitHub integration
      gh = { enabled = true },

      -- Explorer layout customization
      picker = {
        sources = {
          explorer = {
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

      dashboard = { enabled = false },
      words = { enabled = false },
      statuscolumn = { enabled = true },
      scope = { enabled = true },
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
