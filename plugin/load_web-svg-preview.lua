vim.api.nvim_create_user_command("WebSvgPreview", function()
	package.loaded["web-svg-preview"] = nil
	require("web-svg-preview").setup()
end, {})

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.svg",
	callback = function()
		vim.keymap.set("n", "<leader>g", "<cmd>WebSvgPreview<cr>")
	end,
})
