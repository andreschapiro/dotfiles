-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window management
vim.keymap.set("n", "<leader>wd", "<C-w>c", { desc = "Delete/Close window" })
vim.keymap.set("n", "<leader>w-", "<C-w>s", { desc = "Split window below" })
vim.keymap.set("n", "<leader>w|", "<C-w>v", { desc = "Split window right" })
vim.keymap.set("n", "<leader>ww", "<C-w>w", { desc = "Switch windows" })

-- Resize windows with arrows
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Convert tabs to spaces (moved to avoid conflict with TypeScript commands)
-- Use :retab or conform.nvim formatting instead

-- Oil file explorer
vim.keymap.set("n", "-", function()
  require("oil").toggle_float()
end, { desc = "Toggle Oil file explorer" })

-- Clear search highlights on Esc
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and clear hlsearch" })

-- Terminal mode
vim.keymap.set("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })
