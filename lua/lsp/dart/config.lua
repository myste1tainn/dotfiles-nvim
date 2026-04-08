local lspconfig = require("lspconfig")

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "dart" },
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
		vim.opt_local.softtabstop = 2
		-- vim.opt_local.expandtab = true

		-- Disable autolist for dart files, because it interferes with flutter widget editing
		-- require("autolist").setup({ enabled = false })
		-- vim.keymap.set("n", "o", "o", { buffer = true }) -- restore normal o
		-- vim.keymap.set("i", "<CR>", "<CR>", { buffer = true }) -- restore normal <CR>
		-- vim.keymap.set("n", "dd", "dd", { buffer = true }) -- restore normal dd
	end,
})

-- lua/flutter_run.lua
local pidfile = vim.fn.getcwd() .. "/.flutter_run.pid"
local chan
local debounce = vim.loop.new_timer()

-- Start flutter with a PID file
vim.api.nvim_create_user_command("FlutterRun", function()
	if chan then
		vim.notify("Flutter already running", vim.log.levels.WARN)
		return
	end
	pcall(vim.loop.fs_unlink, pidfile) -- remove old file if any

	chan = vim.fn.termopen({ "bash", "-lc", "flutter run --pid-file " .. vim.fn.fnameescape(pidfile) }, {
		on_exit = function()
			chan = nil
			pcall(vim.loop.fs_unlink, pidfile)
			pcall(function()
				debounce:stop()
			end)
			vim.schedule(function()
				vim.notify("flutter run exited", vim.log.levels.INFO)
			end)
		end,
	})

	vim.notify("Starting flutter run… (pid file: " .. pidfile .. ")", vim.log.levels.INFO)
end, {})

-- Helper to read PID
local function read_pid()
	local f = io.open(pidfile, "r")
	if not f then
		return nil
	end
	local s = f:read("*a") or ""
	f:close()
	return tonumber(s:match("%d+"))
end

-- Hot-reload on save using SIGUSR1 (debounced)
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.dart",
	callback = function(args)
		if not chan then
			return
		end
		if vim.fn.filereadable(vim.fn.getcwd() .. "/pubspec.yaml") == 0 then
			return
		end

		debounce:stop()
		debounce:start(200, 0, function()
			local pid = read_pid()
			if not pid then
				vim.schedule(function()
					vim.notify("Flutter PID not ready yet", vim.log.levels.WARN)
				end)
				return
			end
			-- On macOS/libuv: use "SIGUSR1" or "USR1"
			local ok, err = pcall(vim.loop.kill, pid, "SIGUSR1")
			vim.schedule(function()
				if ok then
					vim.notify("Hot reload (SIGUSR1): " .. vim.fn.fnamemodify(args.file, ":."), vim.log.levels.DEBUG)
				else
					vim.notify("Failed to signal flutter: " .. tostring(err), vim.log.levels.ERROR)
				end
			end)
		end)
	end,
})

-- Optional manual hot restart
vim.api.nvim_create_user_command("FlutterRestart", function()
	local pid = read_pid()
	if pid then
		pcall(vim.loop.kill, pid, "SIGUSR2")
		vim.notify("Hot restart (SIGUSR2) sent", vim.log.levels.INFO)
	else
		vim.notify("No flutter PID found", vim.log.levels.WARN)
	end
end, {})

return {
	cmd = { "dart", "language-server", "--protocol=lsp" },
	filetypes = { "dart" },
	root_dir = function(bufnr)
		local path = vim.api.nvim_buf_get_name(bufnr)
		if path == "" then
			return
		end
		return lspconfig.util.root_pattern("pubspec.yaml")(path)
	end,
	-- init_options = {
	-- },
	settings = {
		dart = {
			completeFunctionCalls = true,
			closingLabels = true,
			outline = true,
			onlyAnalyzeProjectsWithOpenFiles = true,
			flutterOutline = true,
			suggestFromUnimportedLibraries = true,
		},
	},
	-- on_attach etc
}
