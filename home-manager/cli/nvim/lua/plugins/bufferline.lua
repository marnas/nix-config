vim.opt.termguicolors = true

-- Close all unfocused buffers
vim.api.nvim_set_keymap("n", "<C-q>", ":%bdelete|edit#|bdelete#<CR>", {})
-- Only close focused buffer
vim.api.nvim_set_keymap("n", "<C-w>", ":bp <cr>:bd# <cr>", {})
-- Rearrange buffers
vim.api.nvim_set_keymap("n", "<leader>bl", ":BufferLineMoveNext <cr>", {})
vim.api.nvim_set_keymap("n", "<leader>bh", ":BufferLineMovePrev <cr>", {})

require("bufferline").setup {
	options = {
		offsets = {
			{
				filetype = "neo-tree",
				text = "File Explorer"
				,
				text_align = "left"
			} },
		show_buffer_close_icons = false,
	}
}
