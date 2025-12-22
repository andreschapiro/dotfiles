return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {
    dir = vim.fn.stdpath("data") .. "/sessions/",
    need = 1,
    branch = true,
  },
  init = function()
    -- Close Sidekick and terminals before saving session
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        -- Close Sidekick CLI before saving session
        local ok, cli = pcall(require, "sidekick.cli")
        if ok then
          pcall(cli.close)
        end
        
        -- Close all terminal buffers before session save
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            local buftype = vim.bo[buf].buftype
            if buftype == "terminal" or buftype == "prompt" then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>qs",
      function()
        require("persistence").load()
        -- Refresh current buffer to trigger LSP and treesitter
        vim.schedule(function()
          vim.cmd("edit")
        end)
      end,
      desc = "Restore Session",
    },
    {
      "<leader>qS",
      function()
        require("persistence").select()
        vim.schedule(function()
          vim.cmd("edit")
        end)
      end,
      desc = "Select Session",
    },
    {
      "<leader>ql",
      function()
        require("persistence").load({ last = true })
        vim.schedule(function()
          vim.cmd("edit")
        end)
      end,
      desc = "Restore Last Session",
    },
    {
      "<leader>qd",
      function()
        require("persistence").stop()
      end,
      desc = "Don't Save Current Session",
    },
  },
}
