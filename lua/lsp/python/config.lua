local root_files = {
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	"pyrightconfig.json",
	".git",
}

return {
	on_attach = function(client, bufnr) end,
	root_markers = root_files,
	-- cmd = { "basedpyright-langserver", "--stdio" },
	single_file_support = true,
	on_new_config = function(new_config, new_root_dir)
		local project_root = new_root_dir or vim.fn.getcwd()
		local poetry_venv = nil
		poetry_venv = vim.fn.system("cd " .. project_root .. "; poetry env info -p"):gsub("%s+", "")
		local python_binary = "python"
		local msg = ""
		if vim.v.shell_error == 0 and vim.fn.isdirectory(poetry_venv) == 1 then
			msg = "Poetry environment detected, using python binary from venv"
			python_binary = poetry_venv .. "/bin/python"
		else
			poetry_venv = nil
			msg = "Using python in PATH (your python)"
		end

		vim.notify(msg, vim.log.levels.INFO, {})

		local config = {
			pythonPath = python_binary, -- Default python binary
			analysis = {
				reportMissingTypeStubs = false, -- Enable type stubs reporting
				reportMissingImports = false, -- Enable type stubs reporting
				reportMissingModuleSuorce = false,
				typeCheckingMode = "reccomended", -- Options: off, basic, strict
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace", -- Options: workspace, openFilesOnly
				autoImportCompletions = true, -- Enable auto import completions
				inlayHints = {
					variableTypes = true, -- Show variable types in inlay hints
					functionReturnTypes = true, -- Show function return types in inlay hints
					genericTypes = true, -- Show generic types in inlay hints
					callArgumentNames = true,
				},
			},
		}

		new_config.settings = {
			basedpyright = config,
			python = config, -- This is the key for basedpyright
		}
	end,
}
