---@diagnostic disable: undefined-global, deprecated

local unpack = table.unpack or unpack

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

local function make_base_settings(python_bin)
	local base = {
		pythonPath = python_bin or "python",
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
	return {
		basedpyright = vim.deepcopy(base),
		python = vim.deepcopy(base),
	}
end

-- Restart all basedpyright clients rooted at `root_dir` with a freshly resolved
-- pythonPath. basedpyright caches site-packages discovery at initialize time, so
-- workspace/didChangeConfiguration is not enough — we need a fresh handshake.
local function restart_clients_with_python(root_dir, python_bin)
	local affected_bufs = {}
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "basedpyright" and client.config.root_dir == root_dir then
			-- Already configured with the same pythonPath? skip
			local current = client.config.settings
				and client.config.settings.basedpyright
				and client.config.settings.basedpyright.pythonPath
			if current == python_bin then
				return
			end
			for bufnr in pairs(client.attached_buffers or {}) do
				table.insert(affected_bufs, bufnr)
			end
			client:stop()
		end
	end

	if #affected_bufs == 0 then
		return
	end

	local settings = make_base_settings(python_bin)
	-- Defer to let the previous client finish stopping
	vim.defer_fn(function()
		local client_id = vim.lsp.start({
			name = "basedpyright",
			cmd = { "basedpyright-langserver", "--stdio" },
			filetypes = { "python" },
			root_dir = root_dir,
			settings = settings,
		})
		if client_id then
			for _, bufnr in ipairs(affected_bufs) do
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.lsp.buf_attach_client(bufnr, client_id)
				end
			end
		end
	end, 150)
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

-- the directory have venv dir, but doesn't have pyproject.toml, but requirements.txt, then
-- we should use the venv python path, not the system python path
local function local_venv_python(root_dir)
	if
		vim.fn.isdirectory(root_dir .. "/venv") == 1
		and vim.fn.filereadable(root_dir .. "/requirements.txt") == 1
		and vim.fn.filereadable(root_dir .. "/pyproject.toml") == 0
	then
		local venv_python = root_dir .. "/venv/bin/python"
		if vim.fn.executable(venv_python) == 1 then
			return venv_python
		end
	end
	return nil
end

-- setup.lua's manual vim.lsp.start() strips on_attach/settings from the registered
-- config, so we wire the dynamic-path resolution via an LspAttach autocmd instead.
local augroup = vim.api.nvim_create_augroup("LspPythonDynamicPath", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or client.name ~= "basedpyright" then
			return
		end

		local root_dir = client.config.root_dir or vim.fn.getcwd()

		local venv_python = local_venv_python(root_dir)
		if venv_python then
			restart_clients_with_python(root_dir, venv_python)
			return
		end

		detect_poetry_python_async(root_dir, function(python_bin)
			vim.schedule(function()
				if python_bin == "python" then
					return
				end
				vim.notify("Poetry venv detected: " .. python_bin, vim.log.levels.INFO)
				restart_clients_with_python(root_dir, python_bin)
			end)
		end)
	end,
})

return {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		-- pyright looks for pyrightconfig.json in the parent dir of the python path,
		-- so the venv dir itself must not be used as the root.
		return require("lspconfig.util").root_pattern(unpack(root_files))(path)
	end,

	settings = make_base_settings("python"),
	single_file_support = true,
}
