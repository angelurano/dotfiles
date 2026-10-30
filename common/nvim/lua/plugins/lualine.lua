return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
    -- Do not load Lualine in virtual console TTYs (TERM=linux)
    cond = function()
      return vim.env.TERM ~= "linux"
    end,
    config = function()
      local colors = {
        bg         = '#0b1015',
        fg         = '#e0e0e0',
        dark_bg    = '#05080a',
        widget_bg  = '#111820',
        accent     = '#ff8d03',
        comment    = '#5c6773',
        green      = '#98c379',
        yellow     = '#ffcc00',
        red        = '#ef4444',
        white      = '#f5f5f5',
        wez_bottom = '#331717',
      }

      -- Custom theme specific to Ayu
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
          a = { fg = colors.comment, bg = colors.wez_bottom, bold = true },
          b = { fg = colors.comment, bg = colors.wez_bottom },
          c = { fg = colors.comment, bg = colors.wez_bottom },
        },
      }

      local function get_theme()
        if vim.g.colors_name == "ayu_dobri" or vim.g.colors_name == "ayu" then
          return ayu_lualine
        end
        return "auto"
      end

      require('lualine').setup({
        options = {
          theme = get_theme(),
          component_separators = { left = '│', right = '│' },
          section_separators = { left = '', right = '' },
          globalstatus = true,
          disabled_filetypes = {
            statusline = { 'snacks_dashboard', 'alpha', 'dashboard', 'terminal', 'snacks_terminal' },
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

      -- Re-evaluate Lualine theme when colorscheme changes dynamically
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          require('lualine').setup({
            options = {
              theme = get_theme(),
            }
          })
        end,
      })
    end
  }
}
