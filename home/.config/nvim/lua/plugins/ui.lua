return {
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = false,
      highlight = {
        keyword = "bg",
      },
      keywords = {
        FIX = { icon = " " },
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO" },
      { "<leader>st", function() require("snacks").picker.todo_comments() end, desc = "[S]earch [T]ODOs" },
      { "<leader>sT", function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "[S]earch TODOs/FIXes only" },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      cmdline = {
        enabled = true,
      },
      popupmenu = {
        enabled = false, -- Disable noice popupmenu, use cmp-cmdline instead
      },
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover = {
          enabled = true,
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
            trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
            luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
            throttle = 50, -- Debounce lsp signature help request by 50ms
          },
          view = nil, -- when nil, use defaults from documentation
          opts = {}, -- merged with defaults from documentation
        },
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
        -- Always show errors prominently
        {
          filter = {
            event = "msg_show",
            kind = "error",
          },
          opts = { skip = false },
        },
        -- Show Lua errors prominently
        {
          filter = {
            event = "msg_show",
            find = "Error executing lua",
          },
          view = "split",
          opts = { enter = true },
        },
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    keys = {
      {
        "<S-Enter>",
        function()
          require("noice").redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline",
      },
      {
        "<leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Last Message",
      },
      {
        "<leader>nh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Message History",
      },
      {
        "<leader>na",
        function()
          require("noice").cmd("pick")
        end,
        desc = "All Messages (Picker)",
      },
      {
        "<leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Dismiss All Messages",
      },
      {
        "<leader>ne",
        function()
          require("noice").cmd("errors")
        end,
        desc = "Error Messages",
      },
      {
        "<c-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Forward",
        mode = { "i", "n", "s" },
      },
      {
        "<c-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Scroll Backward",
        mode = { "i", "n", "s" },
      },
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == "lazy" then
        vim.cmd([[messages clear]])
      end
      require("noice").setup(opts)
    end,
  },
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    opts = {
      preset = "helix", -- Use helix preset for bottom-right compact layout
      delay = 200,
      win = {
        border = "rounded",
        padding = { 1, 2 },
        title_pos = "center",
        wo = {
          winblend = 0,
        },
      },
      layout = {
        width = { min = 20, max = 50 },
        height = { min = 4, max = 25 },
        spacing = 3,
        align = "left",
      },
      show_help = true,
      show_keys = true,
      -- Enable presets for better functionality
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
        },
      },
      spec = {
        -- Leader key groups
        { "<leader>s", group = "[S]earch" },
        { "<leader>g", group = "[G]it" },
        { "<leader>l", group = "[L]azy" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
        { "<leader>t", group = "[T]odo/Toggle" },
        { "<leader>u", group = "[U]ndo" },
        { "<leader>q", group = "[Q]uit/Session" },
        { "<leader>n", group = "[N]otifications" },
        { "<leader>o", group = "[O]pen" },
        { "<leader>b", group = "[B]uffer" },
        { "<leader>w", group = "[W]indow" },
        { "<leader>c", group = "[C]ode" },
        { "<leader>ct", group = "[C]ode [T]ypeScript" },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>x", group = "Diagnostics/Quickfi[x]" },

        -- Ctrl key mappings
        { "<C-f>", desc = "Find files (hidden)" },
        { "<C-b>", desc = "Find buffers" },
        { "<C-g>", desc = "Grep in open buffers" },
        { "<C-x>", desc = "Toggle terminal" },
        { "<C-c>", desc = "Delete buffer" },
        { "<C-h>", desc = "Move to left window" },
        { "<C-j>", desc = "Move to bottom window" },
        { "<C-k>", desc = "Move to top window" },
        { "<C-l>", desc = "Move to right window" },
        { "<C-d>", desc = "Scroll down and center" },
        { "<C-u>", desc = "Scroll up and center" },

        -- G prefix mappings
        { "g", group = "goto" },
        { "gd", desc = "Goto Definition" },
        { "gr", desc = "Goto References" },
        { "gI", desc = "Goto Implementation" },
        { "gD", desc = "Goto Declaration" },

        -- Diagnostic navigation
        { "[d", desc = "Previous Diagnostic" },
        { "]d", desc = "Next Diagnostic" },

        -- LSP actions
        { "K", desc = "Hover Documentation" },
        { "<leader>e", desc = "Show Diagnostic Error" },

        -- Dashboard
        { "<leader>;", desc = "Dashboard" },
      },
    },
  },
}
