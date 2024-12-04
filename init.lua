-- Set up leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.background = "dark"

-- Enable persistent undo
vim.opt.undofile = true

-- Set the directory for undo files
local undodir = vim.fn.stdpath("config") .. "/undo"
vim.opt.undodir = undodir

-- Ensure the undo directory exists
if vim.fn.empty(vim.fn.glob(undodir)) > 0 then
	vim.fn.mkdir(undodir, "p")
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup(require("plugins"))

-- Load plugins
require("nvim-web-devicons").setup({
	-- Optional: Customize icons if desired
	default = true, -- Use default icons
})

--Sitter
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

require("nvim-treesitter.configs").setup({
	ensure_installed = "all", -- or a list of languages
	highlight = {
		enable = true,
	},
	auto_install = true, -- Automatically install missing parsers when entering buffer
})

--Rosepine Setup
require("rose-pine").setup({
	variant = "auto", -- auto, main, moon, or dawn
	dark_variant = "main", -- main, moon, or dawn
	dim_inactive_windows = false,
	extend_background_behind_borders = true,

	enable = {
		terminal = true,
		legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
		migrations = true, -- Handle deprecated options automatically
	},

	styles = {
		bold = true,
		italic = true,
		transparency = false,
	},

	groups = {
		border = "muted",
		link = "iris",
		panel = "surface",

		error = "love",
		hint = "iris",
		info = "foam",
		note = "pine",
		todo = "rose",
		warn = "gold",

		git_add = "foam",
		git_change = "rose",
		git_delete = "love",
		git_dirty = "rose",
		git_ignore = "muted",
		git_merge = "iris",
		git_rename = "pine",
		git_stage = "iris",
		git_text = "rose",
		git_untracked = "subtle",

		h1 = "iris",
		h2 = "foam",
		h3 = "rose",
		h4 = "gold",
		h5 = "pine",
		h6 = "foam",
	},

	palette = {
		-- Override the builtin palette per variant
		-- moon = {
		--     base = '#18191a',
		--     overlay = '#363738',
		-- },
	},

	highlight_groups = {
		-- Comment = { fg = "foam" },
		-- VertSplit = { fg = "muted", bg = "muted" },
	},

	before_highlight = function(group, highlight, palette)
		-- Disable all undercurls
		-- if highlight.undercurl then
		--     highlight.undercurl = false
		-- end
		--
		-- Change palette colour
		-- if highlight.fg == palette.pine then
		--     highlight.fg = palette.foam
		-- end
	end,
})

vim.cmd("colorscheme rose-pine")
-- vim.cmd("colorscheme rose-pine-main")
-- vim.cmd("colorscheme rose-pine-moon")
-- vim.cmd("colorscheme rose-pine-dawn")

local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Initialize Mason
mason.setup()

-- Automatically set up servers
mason_lspconfig.setup({
	automatic_installation = true,
})

mason_lspconfig.setup_handlers({
	function(server_name) -- Default handler for all installed servers
		lspconfig[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})
	end,
})

-- Default capabilities for LSP (for nvim-cmp support)
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Automatically configure servers
mason_lspconfig.setup_handlers({
	function(server_name)
		lspconfig[server_name].setup({
			capabilities = capabilities,
			on_attach = function(_, bufnr)
				-- Keybindings for LSP
				local opts = { noremap = true, silent = true }
				local keymap = vim.api.nvim_buf_set_keymap
				keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
				keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
				keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
				keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
			end,
		})
	end,
})

local cmp = require("cmp")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept completion
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" }, -- LSP completions
		{ name = "luasnip" }, -- Snippets
	}, {
		{ name = "buffer" }, -- Buffer completions
	}),
})

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.prettier, -- JavaScript/TypeScript/CSS/HTML
		null_ls.builtins.formatting.black, -- Python
		null_ls.builtins.formatting.stylua, -- Lua
		null_ls.builtins.diagnostics.eslint, -- JavaScript/TypeScript
		null_ls.builtins.diagnostics.flake8, -- Python
	},
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format()
			end,
		})
	end,
})

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename Symbol" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find References" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })
vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format Buffer" })

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = false,
		refresh = {
			statusline = 100,
			tabline = 100,
			winbar = 100,
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
})
