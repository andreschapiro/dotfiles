-- Terminal Keymaps
vim.keymap.set("n", "<leader>tv", function()
  vim.cmd("vsplit")
  vim.cmd("vertical resize " .. math.floor(vim.o.columns / 3))
  vim.cmd("term")
  vim.cmd("startinsert")
end, { desc = "Open terminal in vertical split (1/3 width)" })
vim.keymap.set("n", "<leader>th", function()
  vim.cmd("split")
  vim.cmd("resize " .. math.floor(vim.o.lines / 3))
  vim.cmd("term")
  vim.cmd("startinsert")
end, { desc = "Open terminal in horizontal split (1/3 height)" })
vim.keymap.set("t", "jk", "<C-\\><C-n>", { desc = "Use jk to enter in terminal normal mode" })
vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Use jk to enter in terminal normal mode" })
vim.keymap.set("t", "<leader>tq", function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd("stopinsert")
  vim.cmd("close")
  if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end, { desc = "Quit terminal and delete buffer" })
vim.keymap.set("n", "<leader>tq", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == "terminal" then
    vim.cmd("close")
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, { desc = "Quit terminal and delete buffer" })

-- Oil file explorer
vim.keymap.set("n", "-", function()
  require("oil").toggle_float()
end, { desc = "Toggle Oil file explorer" })
