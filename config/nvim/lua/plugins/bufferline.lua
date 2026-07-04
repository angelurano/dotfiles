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
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>",  desc = "Close Other Buffers" },

      { "<leader>br", "<cmd>BufferLineCloseRight<cr>",   desc = "Close Buffers to the Right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>",    desc = "Close Buffers to the Left" },
    },
    opts = {
      options = {
        mode = "buffers",
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        show_close_icon = true,
        diagnostics = "nvim_lsp",
        separator_style = "thin",
        custom_filter = function(buf_number, buf_numbers)
          local filetype = vim.bo[buf_number].filetype
          if filetype == "snacks_picker_list" or filetype == "snacks_layout_box" or filetype == "neo-tree" then
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
        },
      },
    },
  },
}
