-- TypeScript/JavaScript support
-- Uses vtsls (recommended over ts_ls) for better performance and features
return {
  -- Configure LSP for TypeScript
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Disable ts_ls in favor of vtsls
      opts.servers = opts.servers or {}
      opts.servers.ts_ls = { enabled = false }

      -- Configure vtsls (better TypeScript LSP)
      opts.servers.vtsls = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
            preferences = {
              importModuleSpecifier = "relative",
            },
          },
        },
      }

      -- Copy typescript settings to javascript
      opts.setup = opts.setup or {}
      opts.setup.vtsls = function(_, server_opts)
        server_opts.settings.javascript =
          vim.tbl_deep_extend("force", {}, server_opts.settings.typescript, server_opts.settings.javascript or {})
      end

      return opts
    end,
  },

  -- TypeScript-specific keymaps (set on LspAttach)
  {
    "neovim/nvim-lspconfig",
    opts = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("typescript-keymaps", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or not vim.tbl_contains({ "vtsls", "ts_ls", "biome" }, client.name) then
            return
          end

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "TS: " .. desc })
          end

          -- Import management (manual, not on save)
          -- vtsls uses different action names than ts_ls
          map("<leader>co", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.organizeImports.ts" }, diagnostics = {} },
            })
          end, "Organize Imports")

          map("<leader>ci", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.addMissingImports.ts" }, diagnostics = {} },
            })
          end, "Add Missing Imports")

          map("<leader>cu", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.removeUnused.ts" }, diagnostics = {} },
            })
          end, "Remove Unused Imports")

          map("<leader>cF", function()
            vim.lsp.buf.code_action({
              apply = true,
              context = { only = { "source.fixAll.ts" }, diagnostics = {} },
            })
          end, "Fix All")
        end,
      })
    end,
  },
}
