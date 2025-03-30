local opts = { noremap = true, silent = true }

-- Shorten function name
local remap = vim.api.nvim_set_keymap

--Remap space as leader key
remap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal --
-- Better window navigation
remap("n", "<C-h>", "<CMD>NavigatorLeft<CR>", opts)
remap("n", "<C-l>", "<CMD>NavigatorRight<CR>", opts)
remap("n", "<C-k>", "<CMD>NavigatorUp<CR>", opts)
remap("n", "<C-j>", "<CMD>NavigatorDown<CR>", opts)

-- Resize with arrows
remap("n", "<C-Up>", ":resize +2<CR>", opts)
remap("n", "<C-Down>", ":resize -2<CR>", opts)
remap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
remap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
-- These unicode characters have been mapped to ctrl-tab and ctrl-shift-tab
remap("n", "⌐", ":bnext<CR>", opts)
remap("n", "¬", ":bprevious<CR>", opts)

-- Better Scrolling
-- remap("n", "<C-N>", "<C-E>", opts)
-- remap("n", "<C-E>", "<C-Y>", opts)

-- Go to first character
remap("n", "0", "^", opts)

-- Clear search highlights
remap("n", "\\\\", ":nohlsearch<CR>", opts)

-- Visual --
-- Stay in indent mode
remap("v", "<S-h>", "<gv", opts)
remap("v", "<S-l>", ">gv", opts)

-- Don't yank after pasting
remap("v", "p", '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>f", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
