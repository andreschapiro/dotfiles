return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "BufReadPost" }, -- Defer until buffer is actually read
    config = function()
      require("gitsigns").setup()
    end,
  },
}
