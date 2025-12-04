return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      go = { "gofumpt", "goimports" },
      rust = { "rustfmt" },
      zig = { "zigfmt" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    format_on_save = function(bufnr)
      -- Disable with vim.g.autoformat or vim.b.autoformat
      if not vim.g.autoformat or (vim.b[bufnr].autoformat == false) then
        return
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    -- Custom formatter settings
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" }, -- 2 space indentation
      },
    },
  },
  init = function()
    vim.g.autoformat = true
  end,
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
    {
      "<leader>uf",
      function()
        vim.g.autoformat = not vim.g.autoformat
        local status = vim.g.autoformat and "enabled" or "disabled"
        vim.notify("Autoformat " .. status, vim.log.levels.INFO)
      end,
      desc = "Toggle autoformat",
    },
  },
}
