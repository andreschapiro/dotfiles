vim.api.nvim_create_autocmd("FileType", {
  pattern = "oil",
  callback = function()
    vim.opt_local.colorcolumn = ""
  end,
})

return {
  {
    "stevearc/oil.nvim",
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        -- use_default_keymaps = false,
        confirmation = {
          border = "rounded",
        },
        float = {
          padding = 2,
          max_width = 100,
          max_height = 0.7,
          border = "rounded",
        },
        keymaps = {
          ["<C-l>"] = false,
          ["<C-r>"] = "actions.refresh",
          ["q"] = "actions.close",
        },
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },
}
