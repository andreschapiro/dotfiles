return {
  -- Diagnostic utilities and commands
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Command to send all diagnostics to quickfix list
      vim.api.nvim_create_user_command("DiagnosticsToQF", function(opts)
        local scope = opts.args == "workspace" and "workspace" or "buffer"
        
        if scope == "workspace" then
          -- Get diagnostics from all buffers
          vim.diagnostic.setqflist({ open = true })
          local count = #vim.fn.getqflist()
          vim.notify(
            string.format("Added %d workspace diagnostics to quickfix", count),
            vim.log.levels.INFO,
            { title = "Diagnostics" }
          )
        else
          -- Get diagnostics from current buffer only
          vim.diagnostic.setloclist({ open = true })
          local count = #vim.fn.getloclist(0)
          vim.notify(
            string.format("Added %d buffer diagnostics to location list", count),
            vim.log.levels.INFO,
            { title = "Diagnostics" }
          )
        end
      end, {
        desc = "Send diagnostics to quickfix/location list",
        nargs = "?",
        complete = function()
          return { "buffer", "workspace" }
        end,
      })

      -- Command to search workspace diagnostics with snacks picker
      vim.api.nvim_create_user_command("DiagnosticsWorkspace", function()
        -- Get all diagnostics from all buffers
        local all_diagnostics = vim.diagnostic.get()
        
        if #all_diagnostics == 0 then
          vim.notify("No diagnostics found in workspace", vim.log.levels.INFO)
          return
        end
        
        vim.notify(
          string.format("Found %d diagnostics in workspace", #all_diagnostics),
          vim.log.levels.INFO,
          { title = "Diagnostics" }
        )
        
        -- Use snacks picker for all diagnostics
        require("snacks").picker.diagnostics()
      end, { desc = "Search workspace diagnostics" })
    end,
    keys = {
      -- Diagnostic navigation
      {
        "]d",
        vim.diagnostic.goto_next,
        desc = "Next Diagnostic",
      },
      {
        "[d",
        vim.diagnostic.goto_prev,
        desc = "Previous Diagnostic",
      },
      -- View diagnostics
      {
        "<leader>e",
        vim.diagnostic.open_float,
        desc = "Show Diagnostic Error (Float)",
      },
      {
        "<leader>sd",
        function()
          require("snacks").picker.diagnostics({ scope = "buffer" })
        end,
        desc = "[S]earch [D]iagnostics (Buffer)",
      },
      {
        "<leader>sD",
        "<cmd>DiagnosticsWorkspace<cr>",
        desc = "[S]earch [D]iagnostics (Workspace)",
      },
      -- Quickfix integration
      {
        "<leader>xd",
        "<cmd>DiagnosticsToQF buffer<cr>",
        desc = "Diagnostics to Location List (Buffer)",
      },
      {
        "<leader>xD",
        "<cmd>DiagnosticsToQF workspace<cr>",
        desc = "Diagnostics to Quickfix (Workspace)",
      },
      -- Quickfix navigation
      {
        "]q",
        "<cmd>cnext<cr>",
        desc = "Next Quickfix Item",
      },
      {
        "[q",
        "<cmd>cprev<cr>",
        desc = "Previous Quickfix Item",
      },
      {
        "]l",
        "<cmd>lnext<cr>",
        desc = "Next Location List Item",
      },
      {
        "[l",
        "<cmd>lprev<cr>",
        desc = "Previous Location List Item",
      },
      -- Search quickfix with snacks
      {
        "<leader>sq",
        function()
          require("snacks").picker.qflist()
        end,
        desc = "[S]earch [Q]uickfix List",
      },
      {
        "<leader>sl",
        function()
          require("snacks").picker.loclist()
        end,
        desc = "[S]earch [L]ocation List",
      },
    },
  },
}
