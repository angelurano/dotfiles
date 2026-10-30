return {
  "sheng-tse/jupynvim",
  build = function(plugin)
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
