local options = {
	completeopt = { "menuone", "noselect" }, -- mostly just for cmp
	fileencoding = "utf-8",                 -- the encoding written to a file
	ignorecase = true,                      -- ignore case in search patterns
	mouse = "a",                            -- allow the mouse to be used in neovim
	pumheight = 10,                         -- pop up menu height
	autoread = true,
	smartcase = true,                       -- smart case
	smartindent = true,                     -- make indenting smarter again
	splitbelow = true,                      -- force all horizontal splits to go below current window
	splitright = true,                      -- force all vertical splits to go to the right of current window
	swapfile = false,                       -- creates a swapfile
	termguicolors = true,                   -- set term gui colors (most terminals support this)
	undofile = true,                        -- enable persistent undo
	updatetime = 300,                       -- faster completion (4000ms default)
	writebackup = false,                    -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	shiftwidth = 2,                         -- the number of spaces inserted for each indentation
	tabstop = 2,                            -- insert 2 spaces for a tab
	cursorline = true,                      -- highlight the current line
	number = true,                          -- set numbered lines
	signcolumn = "yes",                     -- always show the sign column, otherwise it would shift the text each time
	scrolloff = 8,                          -- minimal number of screen lines to keep above and below the cursor.
	sidescrolloff = 8,                      -- same horizontal
	guifont = "monospace:h17",              -- the font used in graphical neovim applications
	showmode = false,                       -- we don't need to see things like -- INSERT -- anymore
	showtabline = 2,                        -- always show tabs
	foldenable = false,                     -- disable fold at startup
	foldmethod = 'indent',
	foldlevel = 20,
}

vim.opt.shortmess:append "c"

for key, value in pairs(options) do
	vim.opt[key] = value
end

-- Auto refresh buffer on external changes
-- vim.cmd "au CursorHold * checktime | call feedkeys('lh')"

--vim.cmd "set whichwrap+=<,>,[,],h,l"
--vim.cmd [[set iskeyword+=-]]

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
