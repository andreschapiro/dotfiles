return {
  -- lspconfig
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost" },
    dependencies = {
      "mason.nvim",
      { "williamboman/mason-lspconfig.nvim", config = function() end },
      "saghen/blink.cmp",
      { "j-hui/fidget.nvim" },
    },
    opts = function()
      local ret = {
        -- options for vim.diagnostic.config()
        diagnostics = {
          underline = true,
          update_in_insert = false,
          virtual_text = false, -- Disabled in favor of tiny-inline-diagnostic.nvim
          severity_sort = true,
          signs = true,
          float = {
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
          },
        },
        inlay_hints = {
          enabled = true,
          exclude = {},
        },
        -- Server configurations
        servers = {
          -- Default capabilities and keymaps for all servers
          ["*"] = {
            capabilities = {
              workspace = {
                fileOperations = {
                  didRename = true,
                  willRename = true,
                },
              },
            },
          },
          -- Explicitly disable formatters as LSP servers
          stylua = { enabled = false },
          prettierd = { enabled = false },
          -- Actual LSP servers
          bashls = {},
          biome = {},
          copilot = {}, -- Copilot LSP for sidekick.nvim NES
          cssls = {
            settings = {
              css = { validate = true, lint = {
                unknownAtRules = "ignore",
              } },
              scss = { validate = true, lint = {
                unknownAtRules = "ignore",
              } },
              less = { validate = true, lint = {
                unknownAtRules = "ignore",
              } },
            },
          },
          eslint = {
            autostart = false,
            cmd = { "vscode-eslint-language-server", "--stdio", "--max-old-space-size=12288" },
            settings = { format = false },
          },
          gopls = {
            settings = {
              gopls = {
                analyses = {
                  unusedparams = true,
                },
                staticcheck = true,
                usePlaceholders = true,
                completeUnimported = true,
                gofumpt = true,
              },
            },
          },
          html = {},
          jsonls = {},
          lua_ls = {
            settings = {
              Lua = {
                runtime = { version = "LuaJIT" },
                workspace = {
                  checkThirdParty = false,
                },
                completion = {
                  callSnippet = "Replace",
                },
                diagnostics = {
                  globals = { "vim" },
                },
              },
            },
          },
          marksman = {},
          sqls = {},
          tailwindcss = {
            filetypes = { "typescriptreact", "javascriptreact", "html", "astro" },
          },
          -- ts_ls disabled in favor of vtsls (configured in typescript.lua)
          yamlls = {},
          zls = {},
          rust_analyzer = {
            settings = {
              ["rust-analyzer"] = {
                check = { command = "clippy", features = "all" },
              },
            },
          },
        },
        setup = {},
      }
      return ret
    end,
    config = function(_, opts)
      -- Setup diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- Setup hover and signature help handlers

      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
        ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" }),
      }
      for method, handler in pairs(handlers) do
        vim.lsp.handlers[method] = handler
      end

      -- Note: Diagnostic keybindings are now in diagnostics.lua for centralized management

      -- LSP keybindings (set when LSP attaches to a buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          map("gd", function()
            require("snacks").picker.lsp_definitions()
          end, "[G]oto [D]efinition")

          -- Find references for the word under your cursor.
          map("gr", function()
            require("snacks").picker.lsp_references()
          end, "[G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          map("gI", function()
            require("snacks").picker.lsp_implementations()
          end, "[G]oto [I]mplementation")

          -- Jump to the type of the word under your cursor.
          map("<leader>D", function()
            require("snacks").picker.lsp_type_definitions()
          end, "Type [D]efinition")

          -- Fuzzy find all the symbols in your current document.
          map("<leader>ds", function()
            require("snacks").picker.lsp_symbols()
          end, "[D]ocument [S]ymbols")

          -- Fuzzy find all the symbols in your current workspace.
          map("<leader>ws", function()
            require("snacks").picker.lsp_workspace_symbols()
          end, "[W]orkspace [S]ymbols")

          -- Rename the variable under your cursor.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Hover documentation
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          -- Signature help
          map("<C-k>", vim.lsp.buf.signature_help, "Signature Help", "i")

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          -- Enable inlay hints if supported
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- Setup default capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- Use blink.cmp capabilities instead of nvim-cmp
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink then
        capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
      end

      -- Apply default config to all servers
      if opts.servers["*"] then
        opts.servers["*"].capabilities =
          vim.tbl_deep_extend("force", capabilities, opts.servers["*"].capabilities or {})
        vim.lsp.config("*", opts.servers["*"])
      end

      local have_mason = pcall(require, "mason-lspconfig")
      -- List of servers that are available in Mason
      local mason_all = have_mason
          and {
            "bashls",
            "biome",
            "cssls",
            "eslint",
            "gopls",
            "html",
            "jsonls",
            "lua_ls",
            "marksman",
            "rust_analyzer",
            "tailwindcss",
            "vtsls", -- Better TypeScript LSP (replaces ts_ls)
            "yamlls",
          }
        or {}
      local mason_exclude = {}

      local function configure(server)
        if server == "*" then
          return false
        end
        local sopts = opts.servers[server]
        sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts

        if sopts.enabled == false then
          mason_exclude[#mason_exclude + 1] = server
          return
        end

        local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
        local setup = opts.setup[server] or opts.setup["*"]
        if setup and setup(server, sopts) then
          mason_exclude[#mason_exclude + 1] = server
        else
          vim.lsp.config(server, sopts)
          if not use_mason then
            vim.lsp.enable(server)
          end
        end
        return use_mason
      end

      local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
      if have_mason then
        require("mason-lspconfig").setup({
          ensure_installed = install,
          automatic_enable = { exclude = mason_exclude },
        })
      end
    end,
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = { border = "rounded" },
      ensure_installed = {
        "stylua",
        "prettierd",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)

      -- Check and install tools without blocking refresh
      vim.defer_fn(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local ok, p = pcall(mr.get_package, tool)
          if ok and not p:is_installed() then
            p:install()
          end
        end
      end, 100)
    end,
  },
}
