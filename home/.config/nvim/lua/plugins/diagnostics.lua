-- Diagnostic keymaps (not tied to any plugin, always available)
-- These use built-in vim.diagnostic which is always present
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show Diagnostic Error (Float)" })

vim.keymap.set("n", "<leader>sd", function()
  require("snacks").picker.diagnostics({ filter = { buf = 0 } })
end, { desc = "[S]earch [D]iagnostics (Buffer)" })

vim.keymap.set("n", "<leader>sD", function()
  require("snacks").picker.diagnostics()
end, { desc = "[S]earch [D]iagnostics (Workspace)" })

vim.keymap.set("n", "<leader>xd", function()
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Diagnostics to Location List (Buffer)" })

vim.keymap.set("n", "<leader>xD", function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = "Diagnostics to Quickfix (Workspace)" })

-- Quickfix/Location list navigation
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next Quickfix Item" })
vim.keymap.set("n", "[q", "<cmd>cprev<cr>", { desc = "Previous Quickfix Item" })
vim.keymap.set("n", "]l", "<cmd>lnext<cr>", { desc = "Next Location List Item" })
vim.keymap.set("n", "[l", "<cmd>lprev<cr>", { desc = "Previous Location List Item" })

vim.keymap.set("n", "<leader>sq", function()
  require("snacks").picker.qflist()
end, { desc = "[S]earch [Q]uickfix List" })

vim.keymap.set("n", "<leader>sl", function()
  require("snacks").picker.loclist()
end, { desc = "[S]earch [L]ocation List" })

return {}
