local common = require("user.overseer.templates.rust.common")
local template_name = "Rust: 1. Run"
return {
    name = template_name,
    condition = common.condition,
    params = function()
        local bufnr = vim.api.nvim_get_current_buf()
        local path = vim.api.nvim_buf_get_name(bufnr)
        local root = require("lspconfig.util").root_pattern("Cargo.toml")(path)
            or vim.fs.dirname(vim.fs.find({ "Cargo.toml" }, { upward = true, path = path })[1])
            or vim.fn.getcwd()
        return {
            root = { type = "string", default = root, desc = "Root directory for the Rust project" },
            args = {
                type = "list",
                optional = true,
                default = {},
                desc = "Arguments to pass to the program",
            },
        }
    end,
    builder = function(params)
        return {
            strategy = "jobstart",
            name = "Cargo Run in " .. params.root,
            cmd = { "cargo" },
            args = vim.list_extend({ "run", "--" }, params.args or {}),
            components = {
                "default",
                { "on_output_quickfix", errorformat = "%f:%l:%c: %m" },
            },
            cwd = params.root,
        }
    end,
}
