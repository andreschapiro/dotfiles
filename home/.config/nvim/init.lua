-- Load options first (before plugins, as some plugins check options)
require("config.options")

-- Bootstrap and load plugins via lazy.nvim
-- This loads colorscheme and treesitter with correct priority
require("config.lazy")

-- Load keymaps and autocmds after plugins are loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("config.keymaps")
    require("config.autocmds")
  end,
})
