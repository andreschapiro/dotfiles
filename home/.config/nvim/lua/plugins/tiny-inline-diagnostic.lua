return {
  "rachartier/tiny-inline-diagnostic.nvim",
  event = "LspAttach",
  priority = 1000, -- Load before other diagnostic plugins
  config = function()
    require("tiny-inline-diagnostic").setup({
      preset = "modern", -- Use modern preset for clean look
      options = {
        -- Show diagnostic source
        show_source = true,
        -- Throttle diagnostic updates
        throttle = 20,
        -- Multiple lines for long messages
        multilines = true,
        -- Show all diagnostics on line, not just first
        multiple_diag_under_cursor = true,
        -- Overflow handling
        overflow = {
          mode = "wrap", -- Wrap long messages
        },
        -- Break line options
        break_line = {
          enabled = true,
          after = 80, -- Break after 80 chars
        },
        -- Virt lines options
        virt_texts = {
          priority = 2048,
        },
        -- Severity options
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
          vim.diagnostic.severity.INFO,
          vim.diagnostic.severity.HINT,
        },
      },
    })
  end,
}
