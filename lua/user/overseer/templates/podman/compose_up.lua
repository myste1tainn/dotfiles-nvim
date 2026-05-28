local template_name = "Podman: 2. Compose Up"

local function get_root_dir()
	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == "" then
		return vim.fn.getcwd()
	end
	local dir = vim.fn.fnamemodify(bufpath, ":p:h")
	while dir and dir ~= "/" do
		if
			vim.fn.filereadable(dir .. "/docker-compose.yml") == 1
			or vim.fn.filereadable(dir .. "/docker-compose.yaml") == 1
			or vim.fn.filereadable(dir .. "/compose.yml") == 1
			or vim.fn.filereadable(dir .. "/compose.yaml") == 1
		then
			return dir
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end
	return vim.fn.getcwd()
end

return {
	name = template_name,
	condition = {
		callback = function()
			local root = get_root_dir()
			return vim.fn.filereadable(root .. "/docker-compose.yml") == 1
				or vim.fn.filereadable(root .. "/docker-compose.yaml") == 1
				or vim.fn.filereadable(root .. "/compose.yml") == 1
				or vim.fn.filereadable(root .. "/compose.yaml") == 1
		end,
	},
	params = {},
	builder = function()
		local root = get_root_dir()
		return {
			strategy = "jobstart",
			name = "Podman Compose Up",
			cmd = { "podman" },
			args = { "compose", "up" },
			components = { "default" },
			cwd = root,
		}
	end,
}
