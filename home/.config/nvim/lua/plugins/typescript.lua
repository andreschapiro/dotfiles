-- TypeScript/JavaScript support
-- Uses tsgo + oxlint for diagnostics/code actions
return {
  -- Configure LSP for TypeScript
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Disable previous TS/JS servers in favor of tsgo + oxlint
      opts.servers = opts.servers or {}
      opts.servers.ts_ls = { enabled = false }
      opts.servers.vtsls = { enabled = false }
      opts.servers.biome = { enabled = false }
      opts.servers.eslint = { enabled = false }

      -- Configure tsgo as the primary TypeScript/JavaScript server
      opts.servers.tsgo = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
      }

      -- Configure oxlint for diagnostics
      opts.servers.oxlint = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
      }

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
          if not client or client.name ~= "tsgo" then
            return
          end

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "TS: " .. desc })
          end

          -- Import management (manual, not on save)
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
