return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("codecompanion").setup({
      adapters = {
        acp = {
          claude = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
              },
            })
          end,
        },
      },
      strategies = {
        chat = {
          adapter = "claude",
        },
        inline = {
          adapter = "claude",
        },
      },
      display = {
        chat = {
          window = {
            layout = "vertical", -- vertical|horizontal|float
            width = 0.45,
            height = 0.8,
          },
          show_settings = true,
        },
        inline = {
          diff = {
            enabled = true,
            close_chat_at = 240, -- Close the chat after 240 seconds
          },
        },
      },
      opts = {
        log_level = "ERROR",
        send_code = true,
        use_default_actions = true,
      },
    })

    -- Keymaps
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Toggle chat
    keymap(
      "n",
      "<leader>aa",
      "<cmd>CodeCompanionChat Toggle<cr>",
      vim.tbl_extend("force", opts, { desc = "Toggle CodeCompanion Chat" })
    )
    keymap(
      "v",
      "<leader>aa",
      "<cmd>CodeCompanionChat Toggle<cr>",
      vim.tbl_extend("force", opts, { desc = "Toggle CodeCompanion Chat" })
    )

    -- Open chat with visual selection
    keymap(
      "v",
      "<leader>ac",
      "<cmd>CodeCompanionChat Add<cr>",
      vim.tbl_extend("force", opts, { desc = "Add selection to chat" })
    )

    -- Inline assistant
    keymap(
      { "n", "v" },
      "<leader>ai",
      "<cmd>CodeCompanion<cr>",
      vim.tbl_extend("force", opts, { desc = "Inline CodeCompanion" })
    )

    -- Quick actions
    keymap(
      { "n", "v" },
      "<leader>ap",
      "<cmd>CodeCompanionActions<cr>",
      vim.tbl_extend("force", opts, { desc = "CodeCompanion Actions" })
    )

    -- Explain code
    keymap(
      "v",
      "<leader>ae",
      "<cmd>CodeCompanionChat<cr>Explain this code",
      vim.tbl_extend("force", opts, { desc = "Explain code" })
    )

    -- Fix code
    keymap(
      "v",
      "<leader>af",
      "<cmd>CodeCompanionChat<cr>Fix this code",
      vim.tbl_extend("force", opts, { desc = "Fix code" })
    )

    -- Optimize code
    keymap(
      "v",
      "<leader>ao",
      "<cmd>CodeCompanionChat<cr>Optimize this code",
      vim.tbl_extend("force", opts, { desc = "Optimize code" })
    )

    -- Write tests
    keymap(
      "v",
      "<leader>at",
      "<cmd>CodeCompanionChat<cr>Write tests for this code",
      vim.tbl_extend("force", opts, { desc = "Write tests" })
    )

    -- Add documentation
    keymap(
      "v",
      "<leader>ad",
      "<cmd>CodeCompanionChat<cr>Add documentation for this code",
      vim.tbl_extend("force", opts, { desc = "Add documentation" })
    )
  end,
}
