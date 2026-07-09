return {
  {
    name = "ayu_dobri",
    dir = vim.fn.stdpath("config") .. "/colors",
    priority = 1000,
    lazy = false,
    config = function()
      vim.cmd.colorscheme("ayu_dobri")

      -- Change the active indentation line color to an orange shade
      local function set_indent_scope_color()
        vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#ff8d03", nocombine = true })
      end

      -- Define the highlight immediately
      set_indent_scope_color()

      -- Ensure it is re-applied if the colorscheme is reloaded
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_indent_scope_color,
      })
    end
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
      transparent_bg_fallback_color = "#0b1015",
      smear_between_buffers = true,
      smear_between_neighbor_lines = true,
    },
  }
}
