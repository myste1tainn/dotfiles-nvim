local template_name = "Podman: 1. Run"

local function get_root_dir()
	local bufpath = vim.api.nvim_buf_get_name(0)
	if bufpath == "" then
		return vim.fn.getcwd()
	end
	-- Walk up from buffer to find Dockerfile
	local dir = vim.fn.fnamemodify(bufpath, ":p:h")
	while dir and dir ~= "/" do
		if vim.fn.filereadable(dir .. "/Dockerfile") == 1 then
			return dir
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end
	return vim.fn.getcwd()
end

local function get_parent_dir_name(root)
	return vim.fn.fnamemodify(root, ":t")
end

local function get_expose_port_from_dockerfile(root)
	local dockerfile = root .. "/Dockerfile"
	local f = io.open(dockerfile, "r")
	if not f then
		return nil
	end
	for line in f:lines() do
		local port = line:match("^EXPOSE%s+(%d+)")
		if port then
			f:close()
			return tonumber(port)
		end
	end
	f:close()
	return nil
end

return {
	name = template_name,
	condition = {
		callback = function()
			local root = get_root_dir()
			return vim.fn.filereadable(root .. "/Dockerfile") == 1
		end,
	},
	params = function()
		local root = get_root_dir()
		local dir_name = get_parent_dir_name(root)
		local internal_port = get_expose_port_from_dockerfile(root)
		return {
			container_name = {
				type = "string",
				default = dir_name,
				desc = "Container Name",
			},
			image_name = {
				type = "string",
				default = dir_name,
				desc = "Image Name",
			},
			expose_port = {
				type = "number",
				default = 8080,
				desc = "Expose Port",
			},
			_internal_port = {
				type = "number",
				default = internal_port or 80,
				desc = "Internal port (from Dockerfile EXPOSE)",
			},
		}
	end,
	builder = function(params)
		return {
			strategy = "jobstart",
			name = "Podman Run " .. params.container_name,
			cmd = { "podman" },
			args = {
				"run",
				"-d",
				"--name",
				params.container_name,
				"-p",
				params.expose_port .. ":" .. params._internal_port,
				params.image_name,
			},
			components = { "default" },
		}
	end,
}
