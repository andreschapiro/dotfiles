-- Backdrop handled by snacks.nvim backdrop module

-- Go files: Don't display tabs (Go uses tabs for indentation)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.opt_local.list = false -- Don't show whitespace characters in Go files
		vim.opt_local.expandtab = false -- Keep tabs as tabs (Go standard)
		vim.opt_local.tabstop = 4 -- Go standard tab width
		vim.opt_local.shiftwidth = 4 -- Go standard indent
	end,
})
