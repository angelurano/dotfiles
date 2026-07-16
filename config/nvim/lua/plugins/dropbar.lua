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

    -- Disable bold styling in WinBar and WinBarNC (where dropbar is rendered)
    local function clear_winbar_bold()
      for _, group in ipairs({ 'WinBar', 'WinBarNC' }) do
        local hl = vim.api.nvim_get_hl(0, { name = group })
        if hl then
          local new_hl = vim.tbl_extend('force', hl, { bold = false })
          if new_hl.cterm then
            new_hl.cterm = vim.tbl_extend('force', new_hl.cterm, { bold = false })
          end
          vim.api.nvim_set_hl(0, group, new_hl)
        end
      end
    end

    -- Apply changes immediately and whenever the colorscheme is loaded/reloaded
    clear_winbar_bold()
    vim.api.nvim_create_autocmd('ColorScheme', {
      callback = clear_winbar_bold,
    })
  end,
}
