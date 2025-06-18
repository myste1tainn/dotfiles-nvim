local keymap = vim.keymap.set
local opts = {
	noremap = true,
	silent = true,
}
-- NOTE: These are keymaps that can be used outside of Obsidian.nvim
-- note management
keymap({ "n", "v", "i" }, "<M-e>", "<Esc>:ObsidianOpen ", opts)
keymap({ "n", "v", "i" }, "<M-o>", "<Esc>:ObsidianNew ", opts)
keymap({ "n", "v", "i" }, "<M-u>", "<Esc>:ObsidianNewFromTemplate ", opts)
keymap({ "n", "v" }, "<C-e>", "<Cmd>ObsidianExtractNote<CR>", opts)
-- linking and navigation management
keymap("n", "gt", ":ObsidianTags ", opts)

local vaults_path = vim.fn.expand("~/Library/CloudStorage/GoogleDrive-a.keereena@gmail.com/My Drive")
vim.api.nvim_create_autocmd("BufReadPre", {
	pattern = "*.md", -- match broadly
	callback = function(args)
		opts.bufnr = args.buf
		local full_path = vim.api.nvim_buf_get_name(args.buf)
		if full_path:sub(1, #vaults_path) == vaults_path then
			-- linking and navigation management
			keymap({ "n", "v", "i" }, "<C-l>", "<Esc><Cmd>ObsidianLinks<CR>", opts)
			keymap({ "n", "v" }, "<C-k>", "<Cmd>ObsidianLink<CR>", opts)
			keymap({ "n", "v" }, "<C-j>", "<Cmd>ObsidianLinkNew<CR>", opts)
			keymap("n", "gd", "<Cmd>ObsidianFollowLink<CR>", opts)
			keymap("n", "gr", "<Cmd>ObsidianBacklinks<CR>", opts)
			keymap("n", "gR", ":ObsidianRename ", opts)

			-- editing
			keymap({ "n", "v", "i" }, "<C-v>", "<Esc><Cmd>ObsidianPasteImg ", opts)

			-- set conceallevel to 2 for better link visibility
			vim.api.nvim_buf_set_option(bufnr, "conceallevel", 2)
		end
	end,
})
return {
	-- Obsidian.nvim for vaults and linking
	{
		"epwalsh/obsidian.nvim",
		version = "*",
		lazy = false,
		-- event = { "BufReadPre " .. vaults_path .. "/**.md" },
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("obsidian").setup({
				workspaces = {
					{
						name = "Personal",
						path = vaults_path,
					},
					-- {
					-- 	name = "work",
					-- 	path = "~/vaults/work",
					-- },
				},
				-- ---@diagnostic disable-next-line: missing-fields
				-- completion = {
				-- 	nvim_cmp = true,
				-- },
			})
		end,
	},

	-- Telekasten for daily notes and templates
	{
		"renerocksai/telekasten.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("telekasten").setup({
				-- home = vim.fn.expand("~/vaults/personal"),
				home = vaults_path,
				dailies = "daily",
				weeklies = "weekly",
				templates = "templates",
			})
		end,
	},

	-- Markdown preview (for Mermaid support)
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		ft = { "markdown" },
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
	},

	-- ChatGPT integration for markdown assistance
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("chatgpt").setup({})
		end,
	},

	-- Optional: zk for fast note search and backlinks
	{
		"mickael-menu/zk-nvim",
		config = function()
			require("zk").setup({
				picker = "telescope",
			})
		end,
	},
}
