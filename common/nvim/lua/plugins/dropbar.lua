return {
  'Bekaboo/dropbar.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    local dropbar_api = require('dropbar.api')

    require('dropbar').setup({
      bar = {
        enable = function(buf, win, _)
          buf = vim._resolve_bufnr(buf)
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
            return false
          end
          local ft = vim.bo[buf].filetype or ""
          local name = vim.api.nvim_buf_get_name(buf) or ""
          local excluded_filetypes = {
            'terminal',
            'sidekick_terminal',
            'help',
            'dashboard',
            'NvimTree',
            'DiffviewFiles',
            'DiffviewFileHistory',
            'diff',
          }

          local is_diff = false
          pcall(function()
            is_diff = vim.wo[win].diff
          end)

          if vim.tbl_contains(excluded_filetypes, ft)
              or ft:match("^Diffview")
              or name:match("^diffview://")
              or name:match("^term://")
              or is_diff
              or vim.bo[buf].buftype == 'terminal'
              or vim.w[win].is_terminal_win
              or vim.fn.win_gettype(win) ~= "" then
            return false
          end
          return true
        end,
      },
    })

    -- Keymaps for dropbar navigation
    vim.keymap.set('n', '<leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
    vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
    vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
  end,
}
