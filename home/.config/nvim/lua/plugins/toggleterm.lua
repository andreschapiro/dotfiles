return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
    keys = {
      {
        "<leader>tn",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local float_term = Terminal:new({ direction = "float" })
          float_term:toggle()
        end,
        desc = "Toggle floating terminal",
      },
      {
        "<leader>tb",
        function()
          local Terminal = require("toggleterm.terminal").Terminal
          local bottom_term = Terminal:new({ direction = "horizontal", size = 15 })
          bottom_term:toggle()
        end,
        desc = "Toggle bottom terminal",
      },
      {
        "<leader>tq",
        function()
          -- Get current buffer
          local buf = vim.api.nvim_get_current_buf()
          if vim.bo[buf].buftype == "terminal" then
            -- If we're in a terminal buffer, find the toggleterm instance and close it
            local terms = require("toggleterm.terminal").get_all()
            for _, term in ipairs(terms) do
              if term.bufnr == buf then
                term:close()
                break
              end
            end
          end
        end,
        desc = "Quit current terminal",
        mode = { "n", "t" },
      },
    },
  },
  {
    "ryanmsnyder/toggleterm-manager.nvim",
    dependencies = {
      "akinsho/toggleterm.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local toggleterm_manager = require("toggleterm-manager")
      local actions = toggleterm_manager.actions

      toggleterm_manager.setup({
        mappings = {
          i = {
            ["<CR>"] = { action = actions.toggle_term, exit_on_action = false },
            ["<C-i>"] = { action = actions.create_term, exit_on_action = false },
            ["<C-d>"] = { action = actions.delete_term, exit_on_action = false },
            ["<C-r>"] = { action = actions.rename_term, exit_on_action = false },
          },
          n = {
            ["<CR>"] = { action = actions.toggle_term, exit_on_action = false },
            ["i"] = { action = actions.create_term, exit_on_action = false },
            ["d"] = { action = actions.delete_term, exit_on_action = false },
            ["r"] = { action = actions.rename_term, exit_on_action = false },
          },
        },
        titles = {
          prompt = " Select Terminal ",
          results = " Terminals ",
          preview = " Terminal Preview ",
        },
      })
    end,
    keys = {
      {
        "<leader>tt",
        "<cmd>Telescope toggleterm_manager<cr>",
        desc = "Manage terminals with Telescope",
      },
    },
  },
}
