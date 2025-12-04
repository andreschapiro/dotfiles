return {
  -- Enhanced TypeScript support with native compiler integration
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Enhanced ts_ls configuration
      opts.servers = opts.servers or {}
      opts.servers.ts_ls = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayVariableTypeHintsWhenTypeMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            suggest = {
              completeFunctionCalls = true,
            },
            preferences = {
              importModuleSpecifier = "relative",
              importModuleSpecifierEnding = "minimal",
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
            suggest = {
              completeFunctionCalls = true,
            },
          },
        },
      }
      return opts
    end,
  },
  
  -- TypeScript compiler integration
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Create TypeScript compiler commands
      
      -- Command to check TypeScript types
      vim.api.nvim_create_user_command("TSCheck", function()
        local project_root = vim.fs.dirname(vim.fs.find({ "package.json", "tsconfig.json" }, { upward = true })[1])
        
        if not project_root then
          vim.notify("No TypeScript project found (missing tsconfig.json or package.json)", vim.log.levels.WARN)
          return
        end
        
        vim.notify("Running TypeScript compiler...", vim.log.levels.INFO)

        -- Use tsc from node_modules if available, otherwise global
        local tsc_cmd = project_root .. "/node_modules/.bin/tsc"
        if vim.fn.executable(tsc_cmd) == 0 then
          tsc_cmd = "tsc"
        end
        
        if vim.fn.executable(tsc_cmd) == 0 then
          vim.notify(
            "TypeScript compiler not found. Install with:\n  npm install --global @typescript/native-preview",
            vim.log.levels.ERROR
          )
          return
        end
        
        -- Run tsc --noEmit to check types without emitting files
        vim.fn.jobstart({ tsc_cmd, "--noEmit", "--pretty" }, {
          cwd = project_root,
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data)
            if data and #data > 0 then
              local output = table.concat(data, "\n")
              if output:match("%S") then
                vim.notify(output, vim.log.levels.INFO, { title = "TypeScript Check" })
              end
            end
          end,
          on_stderr = function(_, data)
            if data and #data > 0 then
              local output = table.concat(data, "\n")
              if output:match("%S") then
                vim.notify(output, vim.log.levels.ERROR, { title = "TypeScript Error" })
              end
            end
          end,
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("✓ No TypeScript errors found", vim.log.levels.INFO, { title = "TypeScript Check" })
            else
              vim.notify("✗ TypeScript errors found (exit code: " .. code .. ")", vim.log.levels.ERROR, { title = "TypeScript Check" })
            end
          end,
        })
      end, { desc = "Check TypeScript types with tsc" })
      
      -- Command to build TypeScript project
      vim.api.nvim_create_user_command("TSBuild", function(opts)
        local project_root = vim.fs.dirname(vim.fs.find({ "package.json", "tsconfig.json" }, { upward = true })[1])
        
        if not project_root then
          vim.notify("No TypeScript project found (missing tsconfig.json or package.json)", vim.log.levels.WARN)
          return
        end
        
        vim.notify("Building TypeScript project...", vim.log.levels.INFO)
        
        -- Use tsc from node_modules if available, otherwise global
        local tsc_cmd = project_root .. "/node_modules/.bin/tsc"
        if vim.fn.executable(tsc_cmd) == 0 then
          tsc_cmd = "tsc"
        end
        
        if vim.fn.executable(tsc_cmd) == 0 then
          vim.notify(
            "TypeScript compiler not found. Install with:\n  npm install --global @typescript/native-preview",
            vim.log.levels.ERROR
          )
          return
        end
        
        -- Build with tsc
        local cmd_args = { tsc_cmd }
        if opts.args ~= "" then
          vim.list_extend(cmd_args, vim.split(opts.args, " "))
        end
        
        vim.fn.jobstart(cmd_args, {
          cwd = project_root,
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, data)
            if data and #data > 0 then
              local output = table.concat(data, "\n")
              if output:match("%S") then
                vim.notify(output, vim.log.levels.INFO, { title = "TypeScript Build" })
              end
            end
          end,
          on_stderr = function(_, data)
            if data and #data > 0 then
              local output = table.concat(data, "\n")
              if output:match("%S") then
                vim.notify(output, vim.log.levels.ERROR, { title = "TypeScript Build Error" })
              end
            end
          end,
          on_exit = function(_, code)
            if code == 0 then
              vim.notify("✓ TypeScript build successful", vim.log.levels.INFO, { title = "TypeScript Build" })
            else
              vim.notify("✗ TypeScript build failed (exit code: " .. code .. ")", vim.log.levels.ERROR, { title = "TypeScript Build" })
            end
          end,
        })
      end, {
        desc = "Build TypeScript project with tsc",
        nargs = "*",
      })
      
      -- Command to watch TypeScript project
      vim.api.nvim_create_user_command("TSWatch", function()
        local project_root = vim.fs.dirname(vim.fs.find({ "package.json", "tsconfig.json" }, { upward = true })[1])
        
        if not project_root then
          vim.notify("No TypeScript project found (missing tsconfig.json or package.json)", vim.log.levels.WARN)
          return
        end
        
        -- Use tsc from node_modules if available, otherwise global
        local tsc_cmd = project_root .. "/node_modules/.bin/tsc"
        if vim.fn.executable(tsc_cmd) == 0 then
          tsc_cmd = "tsc"
        end
        
        if vim.fn.executable(tsc_cmd) == 0 then
          vim.notify(
            "TypeScript compiler not found. Install with:\n  npm install --global @typescript/native-preview",
            vim.log.levels.ERROR
          )
          return
        end
        
        -- Open terminal with tsc --watch
        vim.cmd("split | terminal " .. tsc_cmd .. " --watch")
        vim.notify("Started TypeScript watch mode", vim.log.levels.INFO)
      end, { desc = "Watch TypeScript project with tsc --watch" })
      
      -- Command to show TypeScript version
      vim.api.nvim_create_user_command("TSVersion", function()
        local project_root = vim.fs.dirname(vim.fs.find({ "package.json", "tsconfig.json" }, { upward = true })[1])
        
        -- Try local first, then global
        local tsc_cmd = "tsc"
        if project_root then
          local local_tsc = project_root .. "/node_modules/.bin/tsc"
          if vim.fn.executable(local_tsc) == 1 then
            tsc_cmd = local_tsc
          end
        end
        
        if vim.fn.executable(tsc_cmd) == 0 then
          vim.notify("TypeScript compiler not found. Install with:\n  npm install --global @typescript/native-preview", vim.log.levels.ERROR)
          return
        end
        
        vim.fn.jobstart({ tsc_cmd, "--version" }, {
          stdout_buffered = true,
          on_stdout = function(_, data)
            if data and #data > 0 then
              local version = table.concat(data, "\n"):gsub("^%s*(.-)%s*$", "%1")
              if version:match("%S") then
                local scope = project_root and " (local)" or " (global)"
                vim.notify(version .. scope, vim.log.levels.INFO, { title = "TypeScript Version" })
              end
            end
          end,
        })
      end, { desc = "Show TypeScript compiler version" })
      
      -- Auto-command to organize imports on save for TS/JS files
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
        callback = function()
          -- Only if LSP is attached
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          for _, client in ipairs(clients) do
            if client.name == "ts_ls" then
              -- Organize imports
              vim.lsp.buf.code_action({
                context = {
                  only = { "source.organizeImports" },
                  diagnostics = {},
                },
                apply = true,
              })
              break
            end
          end
        end,
      })
    end,
    keys = {
      {
        "<leader>ctc",
        "<cmd>TSCheck<cr>",
        desc = "TypeScript: Check types",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>ctb",
        "<cmd>TSBuild<cr>",
        desc = "TypeScript: Build",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>ctw",
        "<cmd>TSWatch<cr>",
        desc = "TypeScript: Watch",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>ctv",
        "<cmd>TSVersion<cr>",
        desc = "TypeScript: Version",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>cto",
        function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source.organizeImports" },
              diagnostics = {},
            },
            apply = true,
          })
        end,
        desc = "TypeScript: Organize imports",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>cti",
        function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source.addMissingImports" },
              diagnostics = {},
            },
            apply = true,
          })
        end,
        desc = "TypeScript: Add missing imports",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
      {
        "<leader>ctr",
        function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source.removeUnused" },
              diagnostics = {},
            },
            apply = true,
          })
        end,
        desc = "TypeScript: Remove unused",
        ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      },
    },
  },
}
