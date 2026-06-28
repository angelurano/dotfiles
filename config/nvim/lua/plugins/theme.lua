return {
  {
    "ribru17/bamboo.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("bamboo").setup {}
      require("bamboo").load()
    end
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  }
}
