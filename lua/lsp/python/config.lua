local poetry_venv = nil
poetry_venv = vim.fn.system("poetry env info -p"):gsub("%s+", "")
local python_binary = "python"
local venv_path = nil
local venv_name = nil
local msg = ""
if vim.v.shell_error == 0 and vim.fn.isdirectory(poetry_venv) == 1 then
	msg = "Poetry environment detected, using python binary from venv"
	python_binary = poetry_venv .. "/bin/python"
	venv_path = vim.fn.fnamemodify(poetry_venv, ":h") -- dirname
	venv_name = vim.fn.fnamemodify(poetry_venv, ":t") -- basename
else
	poetry_venv = nil
	msg = "Using python in PATH (your python)"
end
vim.schedule(function()
	vim.notify(msg, vim.log.levels.INFO, {})
end)

local util = require("lspconfig.util")

local root_files = {
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	"pyrightconfig.json",
	".git",
}

local function organize_imports()
	local params = {
		command = "basedpyright.organizeimports",
		arguments = { vim.uri_from_bufnr(0) },
	}

	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
		name = "basedpyright",
	})
	for _, client in ipairs(clients) do
		client.request("workspace/executeCommand", params, nil, 0)
	end
end

local function set_python_path(path)
	local clients = vim.lsp.get_clients({
		bufnr = vim.api.nvim_get_current_buf(),
		name = "basedpyright",
	})
	for _, client in ipairs(clients) do
		print("Setting python path for client: " .. client.name)
		if client.settings then
			client.settings.python = vim.tbl_deep_extend("force", client.settings.python or {}, { pythonPath = path })
		else
			client.config.settings =
				vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
		end
		print(
			"Setting python path to: " .. path,
			" for client: " .. client.name,
			" with settings: ",
			vim.inspect(client.settings)
		)
		client.notify("workspace/didChangeConfiguration", { settings = nil })
	end
	print("Python path set to: " .. path)
end

local config = {
	-- python = python_binary,
	analysis = {
		reportMissingTypeStubs = false, -- Enable type stubs reporting
		reportMissingImports = false, -- Enable type stubs reporting
		reportMissingModuleSuorce = false,
		typeCheckingMode = "basic", -- Options: off, basic, strict
		autoSearchPaths = true,
		useLibraryCodeForTypes = true,
		diagnosticMode = "workspace", -- Options: workspace, openFilesOnly
	},
	-- venvPath = venv_path, -- Adjust this path as needed
	-- venv = venv_name, -- Adjust this to your virtual environment name
}

return {
	on_attach = function(client, bufnr) end,
	root_dir = function(fname)
		return util.root_pattern(unpack(root_files))(fname)
	end,
	single_file_support = true,
	settings = {
		basedpyright = config,
		python = config,
	},
	commands = {
		PyrightOrganizeImports = {
			organize_imports,
			description = "Organize Imports",
		},
		PyrightSetPythonPath = {
			set_python_path,
			description = "Reconfigure basedpyright with the provided python path",
			nargs = 1,
			complete = "file",
		},
	},
	docs = {
		description = [[
https://detachhead.github.io/basedpyright

`basedpyright`, a static type checker and language server for python
]],
	},
}
