return {
  "sheng-tse/jupynvim",
  cond = function()
    local is_win = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
    if is_win then
      return vim.fn.executable("cargo") == 1 or vim.fn.executable("jupynvim-core") == 1
    end
    return true
  end,
  build = function(plugin)
    local is_win = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
    if is_win and vim.fn.executable("cargo") ~= 1 then
      return
    end
    local install = loadfile(plugin.dir .. "/lua/jupynvim/install.lua")()
    install.run(plugin)
  end,
  opts = {
    log_level = "info",
    image_renderer = "placeholder", -- "placeholder" uses Kitty Unicode placeholders (required for animated GIFs)
  },
  config = function(_, opts)
    require("jupynvim").setup(opts)
  end,
}
