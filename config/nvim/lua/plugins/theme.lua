return {
  {
    "ribru17/bamboo.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("bamboo").setup {}
      require("bamboo").load()

      -- Cambiar el color de la línea de indentación activa a un tono anaranjado
      local function set_indent_scope_color()
        vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#ff9e64", nocombine = true })
      end

      -- Definir el highlight de forma inmediata
      set_indent_scope_color()

      -- Asegurar que se vuelva a aplicar si se recarga el colorscheme
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_indent_scope_color,
      })
    end
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  }
}
