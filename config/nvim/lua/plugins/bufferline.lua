return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    keys = {
      { "<Tab>",      "<cmd>BufferLineCycleNext<cr>",    desc = "Next Buffer" },
      { "<S-Tab>",    "<cmd>BufferLineCyclePrev<cr>",    desc = "Prev Buffer" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      {
        "<leader>q",
        function()
          local win = vim.api.nvim_get_current_win()
          local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""
          local special_fts = {
            lazy = true,
            mason = true,
            lspinfo = true,
            help = true,
            qf = true,
            checkhealth = true,
          }
          if is_floating or special_fts[vim.bo.filetype] then
            vim.api.nvim_feedkeys("q", "m", true)
            return
          end

          local bufs = vim.fn.getbufinfo({ buflisted = 1 })
          if #bufs <= 1 then
            vim.cmd("q")
          else
            if _G.Snacks and _G.Snacks.bufdelete then
              _G.Snacks.bufdelete()
            else
              vim.cmd("bd")
            end
          end
        end,
        desc = "Smart Close Buffer",
      },
      {
        "<leader>x",
        function()
          local win = vim.api.nvim_get_current_win()
          local is_floating = vim.api.nvim_win_get_config(win).relative ~= ""
          local special_fts = {
            lazy = true,
            mason = true,
            lspinfo = true,
            help = true,
            qf = true,
            checkhealth = true,
          }
          if is_floating or special_fts[vim.bo.filetype] then
            vim.api.nvim_feedkeys("q", "m", true)
            return
          end

          -- Save the current buffer if it is modifiable and has a file
          if vim.bo.modifiable and vim.bo.buftype == "" and vim.fn.empty(vim.fn.expand("%")) == 0 then
            pcall(function() vim.cmd("w") end)
          end

          local bufs = vim.fn.getbufinfo({ buflisted = 1 })
          if #bufs <= 1 then
            vim.cmd("q")
          else
            if _G.Snacks and _G.Snacks.bufdelete then
              _G.Snacks.bufdelete()
            else
              vim.cmd("bd")
            end
          end
        end,
        desc = "Save and Smart Close Buffer",
      },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Other Buffers" },

      { "<leader>br", "<cmd>BufferLineCloseRight<cr>",  desc = "Close Buffers to the Right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",   desc = "Close Buffers to the Left" },
    },
    opts = {
      options = {
        mode = "buffers",
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = true,
        diagnostics = "nvim_lsp",
        separator_style = { '', '│' },
        custom_filter = function(buf_number, _)
          local filetype = vim.bo[buf_number].filetype
          if filetype == "snacks_picker_list" or filetype == "snacks_layout_box" or filetype == "neo-tree" or filetype == "sidekick_terminal" or filetype == "terminal" then
            return false
          end
          return true
        end,
        offsets = {
          {
            filetype = "snacks_layout_box",
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
          {
            filetype = "sidekick_terminal",
            text = "Sidekick",
            text_align = "right",
            separator = true,
          },
        },
      },
    },
  },
}
