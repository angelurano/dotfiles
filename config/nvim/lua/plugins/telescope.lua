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
      { '<leader>fs',  '<cmd>Telescope git_status<cr>',   desc = 'See git status' },
      { '<leader>fgc', '<cmd>Telescope git_commits<cr>',  desc = 'Git commit' },
      { '<leader>fgb', '<cmd>Telescope git_branches<cr>', desc = 'Git commit' },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
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
    },
  }
}
