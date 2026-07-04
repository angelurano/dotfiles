return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>fa',  '<cmd>Telescope<cr>',              desc = 'Find Anything' },
      { '<leader>ff',  '<cmd>Telescope find_files<cr>',   desc = 'Find Files' },
      { '<leader>fb',  '<cmd>Telescope buffers<cr>',      desc = 'Find Buffers' },
      { '<leader>fh',  '<cmd>Telescope help_tags<cr>',    desc = 'Help Tags' },
      { '<leader>fk',  '<cmd>Telescope keymaps<cr>',      desc = 'See keymaps' },
      { '<leader>fg',  '<cmd>Telescope live_grep<cr>',    desc = 'Live Grep' },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['J'] = actions.preview_scrolling_down,
              ['K'] = actions.preview_scrolling_up,
            },
            n = {
              ['J'] = actions.preview_scrolling_down,
              ['K'] = actions.preview_scrolling_up,
            },
          },
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.5,
            },
            width = 0.8,
            height = 0.8,
            preview_cutoff = 120,
          },
          sorting_strategy = "ascending",
          winblend = 0,
        },
      }
    end,
  }
}
