require("codecompanion").setup({
	strategies = {
		chat = {
			adapter = "copilot",
		},
		inline = {
			adapter = "copilot",
		},
	},
	display = {
		action_palette = {
			-- width = 95,
			-- height = 10,
			prompt = "Prompt ",               -- Prompt used for interactive LLM calls
			provider = "telescope",           -- default|telescope|mini_pick
			opts = {
				show_default_actions = true,    -- Show the default actions in the action palette?
				show_default_prompt_library = true, -- Show the default prompt library in the action palette?
			},
		},
	},
	-- adapters = {
	-- 	copilot = function()
	-- 		return require("codecompanion.adapters").extend("copilot", {
	-- 			env = {
	-- 				api_key = "cmd:op read op://personal/OpenAI/credential --no-newline",
	-- 			},
	-- 		})
	-- 	end,
	-- },
})

vim.api.nvim_set_keymap('n', '<leader>cc', ':CodeCompanion ', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ch', ':CodeCompanionChat<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ca', ':CodeCompanionActions<CR>', { noremap = true, silent = true })
