local poetry_venv = vim.fn.system("poetry env info -p"):gsub("%s+", "")
local python_binary = "python"
local msg = ""
if vim.v.shell_error == 0 and vim.fn.isdirectory(poetry_venv) == 1 then
	msg = "Poetry environment detected, using python binary from venv"
	python_binary = poetry_venv .. "/bin/python"
else
	msg = "Using python in PATH (your python)"
end
vim.schedule(function()
	vim.notify(msg, vim.log.levels.INFO, {})
end)

config = {
	python = python_binary,
	analysis = {
		reportMissingTypeStubs = false, -- Enable type stubs reporting
		reportMissingImports = false, -- Enable type stubs reporting
		reportMissingModuleSuorce = false,
		typeCheckingMode = "basic", -- Options: off, basic, strict
		autoSearchPaths = true,
		useLibraryCodeForTypes = true,
		diagnosticMode = "workspace", -- Options: workspace, openFilesOnly
	},
	-- venvPath = "/path/to/your/virtualenvs", -- Adjust this path as needed
	-- venv = "your-venv-name", -- Adjust this to your virtual environment name
}

return {
	on_attach = function(client, bufnr) end,
	settings = {
		basedpyright = config,
		python = config,
	},
}
