return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      local theme_mgr = require("config.theme")

      if vim.env.TERM == "linux" then
        vim.o.termguicolors = false
        vim.o.background = "dark"
        vim.cmd.colorscheme("retrobox")
      else
        vim.o.termguicolors = true
        local saved = theme_mgr.load_saved()
        local ok = pcall(theme_mgr.apply, saved)
        if not ok then
          vim.cmd.colorscheme("retrobox")
        end
      end

      -- Dynamically adapt Snacks highlights to the active theme
      local function sync_theme_highlights()
        if vim.g.colors_name == "ayu_dobri" then
          vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#ff8d03", nocombine = true })
        else
          -- Restore native semantic links so Gruvbox/Retrobox control the palette
          vim.api.nvim_set_hl(0, "SnacksIndentScope", { link = "Special" })
          vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { link = "CursorLine" })
          vim.api.nvim_set_hl(0, "SnacksPickerMatch", { link = "Special" })
          vim.api.nvim_set_hl(0, "SnacksPickerSelected", { link = "Special" })
          vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Directory" })
          vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { link = "FloatBorder" })
          vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { link = "Title" })
        end
      end

      sync_theme_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = sync_theme_highlights,
      })
    end,
  },
  {
    name = "ayu_dobri",
    dir = vim.fn.stdpath("config") .. "/colors",
    priority = 1000,
    lazy = false,
  },
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      hide_target_hack = false,
      never_draw_over_target = true,
      stiffness = 0.55,
      trailing_stiffness = 0.22,
      trailing_exponent = 3.0,
      damping = 0.8,
      max_length = 35,
      cursor_color = "#ff8d03",
      particles_enabled = false,
      anticipation = 0,
      -- transparent_bg_fallback_color = "#0b1015",
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
    },
  }
}
