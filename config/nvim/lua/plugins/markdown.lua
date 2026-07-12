return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    init = function()
      vim.g.mkdp_echo_preview_url = 1

      -- Check if the precompiled binary is installed
      local plugin_dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
      local bin_dir = plugin_dir .. "/app/bin"

      if vim.fn.isdirectory(bin_dir) == 0 or vim.fn.glob(bin_dir .. "/*") == "" then
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function()
            -- Schedule the notification to prevent Neovim's 'Press ENTER' prompt on buffer draw
            vim.schedule(function()
              vim.notify(
                "Markdown Preview: Binary not installed. Run ':MarkdownPreviewBuild'",
                vim.log.levels.WARN,
                { title = "Markdown Preview" }
              )
            end)
          end,
        })
      end

      -- Define custom command to build the plugin manually from inside Neovim
      vim.api.nvim_create_user_command("MarkdownPreviewBuild", function()
        vim.notify("Installing Markdown Preview binaries in the background...", vim.log.levels.INFO,
          { title = "Markdown Preview" })
        local dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app"

        local cmd
        if vim.fn.has("win32") == 1 then
          cmd = { "cmd.exe", "/c", "install.cmd" }
        else
          cmd = { "bash", "./install.sh" }
        end

        vim.fn.jobstart(cmd, {
          cwd = dir,
          on_exit = function(_, exit_code)
            if exit_code == 0 then
              vim.notify("Markdown Preview built successfully!", vim.log.levels.INFO, { title = "Markdown Preview" })
            else
              vim.notify("Markdown Preview build failed. Check your connection.", vim.log.levels.ERROR,
                { title = "Markdown Preview" })
            end
          end,
        })
      end, {})
    end,
  },
}
