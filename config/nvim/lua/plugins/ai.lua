return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    enabled = function()
      return vim.fn.executable("node") == 1 or vim.fn.executable("bun") == 1
    end,
    opts = function()
      local node_cmd = "node"
      -- Use bun if node is missing but bun is present
      if vim.fn.executable("node") == 0 and vim.fn.executable("bun") == 1 then
        node_cmd = "bun"
      end
      return {
        copilot_node_command = node_cmd,
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = "<Tab>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
      }
    end,
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Dismiss copilot suggestion when blink.cmp menu is open
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          require("copilot.suggestion").dismiss()
          vim.b.copilot_suggestion_hidden = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })
    end,
  },
  {
    "folke/sidekick.nvim",
    cmd = "Sidekick",
    enabled = function()
      return vim.fn.executable("node") == 1
          or vim.fn.executable("bun") == 1
          or vim.fn.executable("agy") == 1
    end,
    keys = {
      { "<leader>aa", function() require("sidekick.cli").toggle() end, mode = { "n", "v" }, desc = "Toggle AI CLI" },
      { "<leader>aj", function() require("sidekick.nes").jump() end,   mode = { "n" },      desc = "Jump to Next AI Suggestion" },
      { "<leader>ay", function() require("sidekick.nes").apply() end,  mode = { "n" },      desc = "Accept (Apply) AI Suggestion" },
      { "<leader>an", function() require("sidekick.nes").cancel() end, mode = { "n" },      desc = "Reject (Cancel) AI Suggestion" },
    },
    opts = {
      cli = {
        watch = false,
        win = {
          split = {
            width = 40, -- default 80
          },
          wo = {
            scrolloff = 0,
          },
          config = function(terminal)
            local orig_start = terminal.start
            terminal.start = function(self)
              orig_start(self)
              pcall(vim.api.nvim_clear_autocmds, { event = "WinEnter", group = self.group })
            end
          end,
        },
        tools = {
          antigravity = {},
        },
      },
    },
    config = function(_, opts)
      local session = require("sidekick.cli.session")
      session.did_setup = true
      session.register("terminal", require("sidekick.cli.terminal"))

      require("sidekick").setup(opts)
      -- Restrict sidekick to only antigravity
      require("sidekick.config").cli.tools = {
        antigravity = {}
      }
    end,
  },
}
