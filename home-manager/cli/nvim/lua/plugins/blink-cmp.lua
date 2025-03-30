local blink = require('blink.cmp')

local opts = {
	keymap = { preset = 'default' },
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = 'mono'
	},
	completion = {
		menu = {
			draw = {
				columns = {
					{ "label",     "label_description", gap = 1 },
					{ "kind_icon", "kind" }
				}
			}
		}
	},
	signature = { enabled = true },
	sources = {
		-- remember to enable your providers here
		default = { 'lsp', 'path', 'snippets', 'buffer', 'digraphs' },
		providers = {
			-- create provider
			digraphs = {
				-- IMPORTANT: use the same name as you would for nvim-cmp
				name = 'digraphs',
				module = 'blink.compat.source',

				-- all blink.cmp source config options work as normal:
				score_offset = -3,

				-- this table is passed directly to the proxied completion source
				-- as the `option` field in nvim-cmp's source config
				--
				-- this is NOT the same as the opts in a plugin's lazy.nvim spec
				opts = {
					-- this is an option from cmp-digraphs
					cache_digraphs_on_start = true,

					-- If you'd like to use a `name` that does not exactly match nvim-cmp,
					-- set `cmp_name` to the name you would use for nvim-cmp, for instance:
					-- cmp_name = "digraphs"
					-- then, you can set the source's `name` to whatever you like.
				},
			},
		},
	},
	-- sources = {
	-- 	providers = {
	-- 		lsp = {
	-- 			name = 'LSP',
	-- 			module = 'blink.cmp.sources.lsp',
	-- 			opts = {}, -- Passed to the source directly, varies by source
	--
	-- 			--- NOTE: All of these options may be functions to get dynamic behavior
	-- 			--- See the type definitions for more information
	-- 			enabled = true,       -- Whether or not to enable the provider
	-- 			async = false,        -- Whether we should wait for the provider to return before showing the completions
	-- 			timeout_ms = 2000,    -- How long to wait for the provider to return before showing completions and treating it as asynchronous
	-- 			transform_items = nil, -- Function to transform the items before they're returned
	-- 			should_show_items = true, -- Whether or not to show the items
	-- 			max_items = nil,      -- Maximum number of items to display in the menu
	-- 			min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
	-- 			-- If this provider returns 0 items, it will fallback to these providers.
	-- 			-- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
	-- 			fallbacks = {},
	-- 			score_offset = 0, -- Boost/penalize the score of the items
	-- 			override = nil, -- Override the source's functions
	-- 		}
	-- 	},
	--
	-- },
}

blink.setup(opts)

require('diffview').setup()
