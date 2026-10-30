return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  enabled = function()
    return vim.fn.executable("yazi") == 1
  end,
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>-",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  opts = {
    open_for_directories = true,
    keymaps = {
      show_help = "<f1>",
    },
  },
  -- Recommended when `open_for_directories = true` is set
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
}
