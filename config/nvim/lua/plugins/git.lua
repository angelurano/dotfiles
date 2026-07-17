return {
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function(_, opts)
      require('gitsigns').setup(opts)
      local function set_blame_hl()
        vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', { fg = '#5c6773', italic = true })
      end
      set_blame_hl()
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = set_blame_hl,
      })
    end,
    opts = {
      signcolumn = true,
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Git Add/Reset hunks and buffers
        map('n', '<leader>ga', gitsigns.stage_hunk, { desc = 'Git Add (Stage/Unstage Hunk)' })
        map('v', '<leader>ga', function() gitsigns.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { desc = 'Git Add (Stage Range)' })
        map('n', '<leader>gA', gitsigns.stage_buffer, { desc = 'Git Add (Stage Buffer)' })
        map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'Git Reset Hunk' })
        map('v', '<leader>gr', function() gitsigns.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end,
          { desc = 'Git Reset Range' })
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>",          desc = "Diffview Open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Diffview File History (Current File)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>",   desc = "Diffview Project History" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>",         desc = "Diffview Close" },
      {
        "<leader>gc",
        function()
          vim.ui.input({ prompt = "Commit message: " }, function(input)
            if input and input ~= "" then
              local out = vim.fn.system("git commit -m " .. vim.fn.shellescape(input))
              vim.notify(out, vim.log.levels.INFO, { title = "Git Commit" })
            end
          end)
        end,
        desc = "Git Commit"
      },
    },
    opts = function()
      local actions = require("diffview.actions")
      return {
        keymaps = {
          view = {
            -- Easy conflict resolution mappings
            { "n", "<leader>co", actions.conflict_choose("ours"),   { desc = "Choose OURS (local)" } },
            { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS (remote)" } },
            { "n", "<leader>cb", actions.conflict_choose("base"),   { desc = "Choose BASE" } },
            { "n", "<leader>ca", actions.conflict_choose("all"),    { desc = "Choose ALL (keep both)" } },
            { "n", "<leader>cx", actions.conflict_choose("none"),   { desc = "Choose NONE" } },
            { "n", "q",          "<cmd>DiffviewClose<CR>",          { desc = "Close diffview" } },
          },
          file_panel = {
            { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
          },
          file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close diffview" } },
          }
        }
      }
    end
  }
}
