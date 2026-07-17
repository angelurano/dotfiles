return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    config = function()
      local colors = {
        bg        = '#0b1015',
        fg        = '#97a7c8',
        dark_bg   = '#05080a',
        widget_bg = '#111820',
        accent    = '#ff8d03',
        comment   = '#5c6773',
        green     = '#98c379',
        yellow    = '#ffcc00',
        red       = '#ef4444',
        white     = '#f5f5f5',
      }

      local ayu_lualine = {
        normal = {
          a = { fg = colors.white, bg = colors.accent, bold = true },
          b = { fg = colors.white, bg = colors.widget_bg },
          c = { fg = colors.fg, bg = colors.dark_bg },
        },
        insert = {
          a = { fg = colors.white, bg = '#7045af', bold = true },
          b = { fg = colors.white, bg = colors.widget_bg },
        },
        visual = {
          a = { fg = colors.white, bg = colors.green, bold = true },
          b = { fg = colors.white, bg = colors.widget_bg },
        },
        replace = {
          a = { fg = colors.white, bg = colors.red, bold = true },
          b = { fg = colors.white, bg = colors.widget_bg },
        },
        inactive = {
          a = { fg = colors.comment, bg = colors.dark_bg, bold = true },
          b = { fg = colors.comment, bg = colors.dark_bg },
          c = { fg = colors.comment, bg = colors.dark_bg },
        },
      }

      require('lualine').setup({
        options = {
          theme = ayu_lualine,
          component_separators = { left = '│', right = '│' },
          section_separators = { left = '', right = '' },
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'snacks_dashboard', 'alpha', 'dashboard' },
          },
        },
        sections = {
          lualine_a = { { 'mode', right_padding = 2 } },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = {
            {
              'filename',
              path = 1,
              symbols = {
                modified = ' ●',
                readonly = ' 󰌾',
                unnamed = '[No Name]',
                newfile = '[New]',
              }
            }
          },
          lualine_x = { 'filetype' },
          lualine_y = { 'location' },
          lualine_z = {}
        },
      })
    end
  }
}
