return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Indent guides (use Snacks/LazyVim default visuals)
    indent = {
      enabled = true,
    },
    -- Smart buffer deletion
    bufdelete = { enabled = true },
    -- Git repository browser
    gitbrowse = { enabled = true },
    -- Notification system (disabled - using Noice instead)
    notifier = { enabled = false },
    -- Scratch buffer
    scratch = { enabled = true },
    -- Toggle utilities
    toggle = { enabled = true },
    -- Word highlighting
    words = { enabled = true },
    -- Big file handling
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" }, -- marks and diagnostic signs on the left
      right = { "fold", "git" }, -- fold and git signs on the right
    },
    -- Backdrop for floating windows
    backdrop = {
      enabled = true,
      bg = "#1e2127", -- Darker background
      blend = 20, -- Transparency level
    },
    -- Dashboard
    dashboard = {
      enabled = true,
      preset = {
        header = [[
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
        ]],
        -- stylua: ignore
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua require('snacks').picker.files()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua require('snacks').picker.recent()" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua require('snacks').picker.grep()" },
          { icon = " ", key = "s", desc = "Restore Session", action = function()
              require('persistence').load()
              -- Refresh current buffer to trigger LSP and treesitter (only if buffer has a file)
              vim.schedule(function()
                local bufname = vim.api.nvim_buf_get_name(0)
                if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
                  vim.cmd("edit")
                end
              end)
            end
          },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "m", desc = "Mason", action = ":Mason" },
          { icon = " ", key = "k", desc = "Keybinds", action = ":lua require('snacks').picker.keymaps()" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    picker = {
      enabled = true,
      ui_select = true,
      -- Matcher configuration for fuzzy finding
      matcher = {
        frecency = true, -- Enable frecency (frequency + recency) sorting
      },
      layout = {
        cycle = true,
        preset = function()
          return vim.o.columns >= 120 and "custom_horizontal" or "custom_vertical"
        end,
      },
      layouts = {
        custom_horizontal = {
          layout = {
            box = "horizontal",
            backdrop = true,
            width = 0.8,
            height = 0.9,
            border = "none",
            {
              box = "vertical",
              { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
              { win = "list", border = "rounded" },
            },
            {
              win = "preview",
              title = "{preview:Preview}",
              width = 0.5,
              border = "rounded",
              title_pos = "center",
            },
          },
        },
        custom_vertical = {
          layout = {
            box = "vertical",
            backdrop = true,
            width = 0.9,
            height = 0.9,
            border = "none",
            { win = "input", height = 1, border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
            { win = "list", border = "rounded" },
            { win = "preview", title = "{preview:Preview}", height = 0.4, border = "rounded", title_pos = "center" },
          },
        },
      },
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
            -- Use hjkl with Ctrl for navigation
            ["<C-j>"] = { "list_down", mode = { "i", "n" } },
            ["<C-k>"] = { "list_up", mode = { "i", "n" } },
            ["<C-h>"] = { "list_left", mode = { "i", "n" } },
            ["<C-l>"] = { "list_right", mode = { "i", "n" } },
            -- Preview toggle
            ["<a-p>"] = { "preview_toggle", mode = { "i", "n" } },
          },
          wo = {
            winhighlight = "Normal:SnacksPickerInput,FloatBorder:SnacksPickerInputBorder,FloatTitle:SnacksPickerInputTitle,CursorLine:SnacksPickerInputCursorLine",
          },
        },
      },
      -- Configure specific pickers
      sources = {
        files = {
          hidden = true, -- Show hidden files
        },
        grep = {
          hidden = true, -- Search in hidden files
        },
      },
    },
  },
  keys = {
    -- Dashboard
    {
      "<leader>;",
      function()
        require("snacks").dashboard()
      end,
      desc = "Dashboard",
    },
    -- Buffer delete
    {
      "<leader>bd",
      function()
        require("snacks").bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>bD",
      function()
        require("snacks").bufdelete()
        vim.cmd("close") -- Also close the window
      end,
      desc = "Delete Buffer and Window",
    },
    -- Git browse
    {
      "<leader>og",
      function()
        require("snacks").gitbrowse()
      end,
      desc = "Open Git Repository",
    },
    -- Scratch buffer
    {
      "<leader>.",
      function()
        require("snacks").scratch()
      end,
      desc = "Open Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        require("snacks").scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    -- Toggle diagnostics
    {
      "<leader>td",
      function()
        require("snacks").toggle.diagnostics():toggle()
      end,
      desc = "Toggle Diagnostics",
    },
    -- Toggle inlay hints
    {
      "<leader>ih",
      function()
        require("snacks").toggle.inlay_hints():toggle()
      end,
      desc = "Toggle Inlay Hints",
    },
    -- Picker keymaps
    -- File pickers
    {
      "<leader>sf",
      function()
        require("snacks").picker.files()
      end,
      desc = "[S]earch [F]iles",
    },
    {
      "<leader>se",
      function()
        require("snacks").picker.explorer()
      end,
      desc = "[S]earch [E]xplorer",
    },
    {
      "<leader>s.",
      function()
        require("snacks").picker.recent()
      end,
      desc = "[S]earch Recent Files",
    },
    {
      "<leader><leader>",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "[ ] Find existing buffers",
    },
    {
      "<leader>,",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "Switch Buffer",
    },
    -- Search pickers
    {
      "<leader>sg",
      function()
        require("snacks").picker.grep()
      end,
      desc = "[S]earch by [G]rep",
    },
    {
      "<leader>sw",
      function()
        require("snacks").picker.grep_word()
      end,
      desc = "[S]earch current [W]ord",
    },
    {
      "<leader>s/",
      function()
        require("snacks").picker.grep_buffers()
      end,
      desc = "[S]earch [/] in Open Files",
    },
    {
      "<leader>/",
      function()
        require("snacks").picker.lines()
      end,
      desc = "[/] Search in current buffer",
    },
    -- Neovim config search
    {
      "<leader>sc",
      function()
        require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
      end,
      desc = "[S]earch [C]onfig files",
    },
    -- Help and keymaps
    {
      "<leader>sh",
      function()
        require("snacks").picker.help()
      end,
      desc = "[S]earch [H]elp",
    },
    {
      "<leader>sk",
      function()
        require("snacks").picker.keymaps()
      end,
      desc = "[S]earch [K]eymaps",
    },
    -- Note: Diagnostic keybindings moved to diagnostics.lua
    -- Git pickers
    {
      "<leader>gc",
      function()
        require("snacks").picker.git_log()
      end,
      desc = "[G]it [C]ommits",
    },
    {
      "<leader>gs",
      function()
        require("snacks").picker.git_status()
      end,
      desc = "[G]it [S]tatus",
    },
    -- Resume last picker
    {
      "<leader>sr",
      function()
        require("snacks").picker.resume()
      end,
      desc = "[S]earch [R]esume",
    },
    -- Picker of pickers
    {
      "<leader>ss",
      function()
        require("snacks").picker.pickers()
      end,
      desc = "[S]earch [S]elect Picker",
    },
  },
}
