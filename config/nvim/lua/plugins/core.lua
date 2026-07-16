return {
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
    vscode = true
  },
  {
    "NMAC427/guess-indent.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    config = function(_, opts)
      require("persistence").setup(opts)

      -- Wipe out terminal, Sidekick, and Snacks picker/explorer buffers before saving session
      vim.api.nvim_create_autocmd("User", {
        pattern = "PersistenceSavePre",
        callback = function()
          -- Only wipe buffers if we are exiting Neovim, to avoid closing them in the active session
          if vim.v.exiting == vim.NIL then
            return
          end
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_valid(buf) then
              local buftype = vim.bo[buf].buftype
              local filetype = vim.bo[buf].filetype
              local bufname = vim.api.nvim_buf_get_name(buf)

              if buftype == "terminal"
                  or filetype == "sidekick"
                  or string.match(filetype, "^snacks_")
                  or string.match(bufname, "agy") then
                pcall(vim.api.nvim_buf_delete, buf, { force = true })
              end
            end
          end
        end,
      })
    end,
  }
}
