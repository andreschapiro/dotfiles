return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" }, -- Load on entering insert or cmdline mode
  dependencies = {
    {
      "rafamadriz/friendly-snippets",
      lazy = true, -- Only load when needed
    },
    "echasnovski/mini.icons",
    {
      "L3MON4D3/LuaSnip", -- Required for snippet support
      lazy = true, -- Defer loading until first snippet expansion
      build = "make install_jsregexp", -- Optional: for better regex support
    },
  },
  version = "*", -- Use latest version for better cmdline support
  opts = {
    keymap = {
      preset = "default",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<Tab>"] = {
        function(cmp)
          -- Check if blink menu is visible
          if cmp.is_visible() then
            return cmp.select_next()
          else
            return cmp.snippet_forward() or false
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          else
            return cmp.snippet_backward() or false
          end
        end,
        "fallback",
      },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Cmdline completion configuration
    cmdline = {
      enabled = true,
      keymap = {
        ["<Tab>"] = { "show", "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "fallback" }, -- Always execute command, don't accept completion
        ["<C-y>"] = { "accept" }, -- Use C-y to accept completion
        ["<C-e>"] = { "hide", "fallback" },
      },
      completion = {
        menu = {
          auto_show = false, -- Only show on Tab
        },
      },
    },

    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        border = "rounded",
        draw = {
          columns = {
            { "kind_icon" },
            { "label", "label_description", gap = 1 },
          },
          components = {
            kind_icon = {
              text = function(ctx)
                local kind_icon, _, _ = require("mini.icons").get("lsp", ctx.kind)
                return kind_icon .. " "
              end,
              highlight = function(ctx)
                local _, hl, _ = require("mini.icons").get("lsp", ctx.kind)
                return hl
              end,
            },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
        },
      },
      ghost_text = {
        enabled = false,
      },
    },

    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },

    snippets = {
      expand = function(snippet)
        local ok, luasnip = pcall(require, "luasnip")
        if ok then
          luasnip.lsp_expand(snippet)
        end
      end,
      active = function(filter)
        local ok, luasnip = pcall(require, "luasnip")
        if not ok then
          return false
        end
        if filter and filter.direction then
          return luasnip.jumpable(filter.direction)
        end
        return luasnip.in_snippet()
      end,
      jump = function(direction)
        local ok, luasnip = pcall(require, "luasnip")
        if ok then
          luasnip.jump(direction)
        end
      end,
    },
  },
  opts_extend = { "sources.default" },
}
