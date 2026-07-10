return {
  'Bekaboo/dropbar.nvim',
  config = function()
    local dropbar_api = require('dropbar.api')

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
