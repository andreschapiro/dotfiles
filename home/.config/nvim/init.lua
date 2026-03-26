-- Load options first (before plugins, as some plugins check options)
require("config.options")

-- Bootstrap and load plugins via lazy.nvim
-- This loads colorscheme and treesitter with correct priority
require("config.lazy")

-- Load keymaps and autocmds after plugins are loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    local colors = require("config.colorscheme_picker")
    local saved = colors.get_saved()
    if saved and vim.g.colors_name ~= saved then
      colors.apply(saved)
    end
    require("config.keymaps")
    require("config.autocmds")
  end,
})
