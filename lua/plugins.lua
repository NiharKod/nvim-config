return {
	-- Plugin specifications
	{ "folke/which-key.nvim", opts = {} },
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{ "neovim/nvim-lspconfig" }, -- Core LSP plugin
	{ "rose-pine/neovim", name = "rose-pine" },

	-- LSP Installer and Manager
	{
		"williamboman/mason.nvim",
		build = ":MasonUpdate", -- Ensure up-to-date servers and tools
	},
	{
		"williamboman/mason-lspconfig.nvim", -- Mason integration with lspconfig
		dependencies = { "neovim/nvim-lspconfig" },
	},

	-- Completion Framework
	{
		"hrsh7th/nvim-cmp", -- Core auto-completion plugin
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP completions
			"hrsh7th/cmp-buffer", -- Buffer completions
			"hrsh7th/cmp-path", -- Filepath completions
			"hrsh7th/cmp-cmdline", -- Command-line completions
			"saadparwaiz1/cmp_luasnip", -- Snippet completions
			"L3MON4D3/LuaSnip", -- Snippet engine
		},
	},

	-- Snippets and Predefined Snippets
	{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },

	-- LSP Enhancements (Optional)
	{
		"glepnir/lspsaga.nvim", -- Better UI for LSP interactions
		event = "BufRead",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Formatting and Linting
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
}
