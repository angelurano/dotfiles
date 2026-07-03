return {
  -- Copilot configuration with suggestion mode
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
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
}
