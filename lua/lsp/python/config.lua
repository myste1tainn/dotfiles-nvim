local root_files = {
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	"pyrightconfig.json",
	".git",
}

-- Cache python path per root to avoid rerunning Poetry every buffer open
local python_by_root = {}

local function set_python_for_clients(root_dir, python_bin)
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "basedpyright" and client.config.root_dir == root_dir then
			-- Update settings in the client config
			client.config.settings = client.config.settings or {}
			client.config.settings.basedpyright = client.config.settings.basedpyright or {}
			client.config.settings.python = client.config.settings.python or {}

			client.config.settings.basedpyright.pythonPath = python_bin
			client.config.settings.python.pythonPath = python_bin

			-- Notify server of config change (preferred over restart)
			client.notify("workspace/didChangeConfiguration", {
				settings = client.config.settings,
			})
		end
	end
end

local function detect_poetry_python_async(root_dir, cb)
	-- If cached, return immediately
	if python_by_root[root_dir] ~= nil then
		cb(python_by_root[root_dir])
		return
	end

	-- Default
	python_by_root[root_dir] = "python"

	local function finalize(python_bin)
		python_by_root[root_dir] = python_bin
		cb(python_bin)
	end

	-- Neovim 0.10+: vim.system is async
	if vim.system then
		vim.system({ "poetry", "env", "info", "-p" }, { cwd = root_dir, text = true }, function(res)
			if res.code == 0 then
				local venv = (res.stdout or ""):gsub("%s+", "")
				if venv ~= "" and vim.fn.isdirectory(venv) == 1 then
					finalize(venv .. "/bin/python")
					return
				end
			end
			finalize("python")
		end)
		return
	end

	-- Fallback for older Neovim: jobstart is async
	vim.fn.jobstart({ "poetry", "env", "info", "-p" }, {
		cwd = root_dir,
		stdout_buffered = true,
		on_stdout = function(_, data)
			local venv = table.concat(data or {}, "\n"):gsub("%s+", "")
			if venv ~= "" and vim.fn.isdirectory(venv) == 1 then
				finalize(venv .. "/bin/python")
			else
				finalize("python")
			end
		end,
		on_stderr = function()
			finalize("python")
		end,
	})
end

return {
	on_attach = function(client, bufnr) end,
	root_markers = root_files,
	single_file_support = true,

	on_new_config = function(new_config, new_root_dir)
		local root_dir = new_root_dir or vim.fn.getcwd()

		-- Put a fast default first so LSP can start without blocking
		local base_config = {
			pythonPath = "python",
			analysis = {
				reportMissingTypeStubs = false,
				reportMissingImports = false,
				reportMissingModuleSource = false,
				typeCheckingMode = "recommended",
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace",
				autoImportCompletions = true,
				inlayHints = {
					variableTypes = true,
					functionReturnTypes = true,
					genericTypes = true,
					callArgumentNames = true,
				},
			},
		}

		new_config.settings = {
			basedpyright = vim.deepcopy(base_config),
			python = vim.deepcopy(base_config),
		}

		-- Background detect Poetry, then update the running clients
		detect_poetry_python_async(root_dir, function(python_bin)
			-- Avoid spamming notifications if many buffers open quickly
			vim.schedule(function()
				if python_bin ~= "python" then
					vim.notify("Poetry venv detected: " .. python_bin, vim.log.levels.INFO)
				end
				set_python_for_clients(root_dir, python_bin)
			end)
		end)
	end,
}
