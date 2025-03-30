function on_attach(client, bufnr)
	-- we create a function that lets us more easily define mappings specific
	-- for LSP related items. It sets the mode, buffer and description for us each time.
	if client.config.name == 'yamlls' and vim.bo.filetype == 'helm' then
		vim.lsp.buf_detach_client(bufnr, client.id)
	end

	local nmap = function(keys, func, desc)
		if desc then
			desc = 'LSP: ' .. desc
		end

		vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
	end

	nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
	-- nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

	nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
	nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
	nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
	nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
	nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
	nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

	-- See `:help K` for why this keymap
	nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
	nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

	-- Lesser used LSP functionality
	nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
	nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
	nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
	nmap('<leader>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, '[W]orkspace [L]ist Folders')

	-- Auto format on save
	vim.cmd [[autocmd BufWritePre <buffer> lua vim.lsp.buf.format()]]
end

-- local function get_capabilities()
-- 	local capabilities = vim.lsp.protocol.make_client_capabilities()
-- 	capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
-- 	capabilities.textDocument.completion.completionItem.snippetSupport = true
-- 	return capabilities
-- end

local servers = {
	lua_ls = {
		Lua = {
			formatters = {
				ignoreComments = true,
			},
			signatureHelp = { enabled = true },
			diagnostics = {
				disable = { 'missing-fields' },
				globals = { 'vim' },
			},
		},
		telemetry = { enabled = false },
		filetypes = { 'lua' },
	},

	nixd = {
		nixd = {
			nixpkgs = {
				expr = [[import (builtins.getFlake "]] .. [[") { }   ]],
			},
			formatting = {
				command = { "nixfmt" }
			},
			diagnostic = {
				suppress = {
					"sema-escaping-with"
				}
			}
		}
	},

	helm_ls = {},

	-- yamlls = {
	-- 	yaml = {
	-- 		schemas = { kubernetes = "*.yaml" },
	-- 	},
	-- },

	gopls = {},
	jsonls = {
		cmd = { 'vscode-json-language-server', '--stdio' },
	},

	terraformls = {},
	tflint = {},

	rust_analyzer = {
		imports = {
			granularity = {
				group = "module",
			},
			prefix = "self",
		},
		cargo = {
			buildScripts = {
				enable = true,
			},
		},
		procMacro = {
			enable = true
		},
	}
}

-- servers.clangd = {},
-- servers.pyright = {},
-- servers.tsserver = {},
-- servers.html = { filetypes = { 'html', 'twig', 'hbs'} },

for server_name, cfg in pairs(servers) do
	require('lspconfig')[server_name].setup({
		capabilities = require('blink-cmp').get_lsp_capabilities(),
		-- capabilities = get_capabilities(),
		on_attach = on_attach,
		settings = cfg,
		filetypes = (cfg or {}).filetypes,
		cmd = (cfg or {}).cmd,
		root_pattern = (cfg or {}).root_pattern,
	})
end
