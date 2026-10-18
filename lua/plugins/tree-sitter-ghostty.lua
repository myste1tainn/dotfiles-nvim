-- Ghostty / cmux config files (~/.config/ghostty/config).
--
-- Ghostty's config format is its own ("a custom, but very simplistic key =
-- value syntax" per its docs) — not INI, TOML or YAML — so there is no existing
-- language environment to reuse. There is a tree-sitter grammar for it, which
-- is the real thing: it ships the parser plus highlight queries, its own
-- ftdetect for the standard config paths, and an ftplugin.
--
-- Neovim itself has no ghostty filetype (checked on 0.12.5) and nvim-treesitter
-- does not carry the parser, so it comes from the grammar's own repo. It builds
-- parser/ghostty.so with the tree-sitter CLI at install time (needs
-- tree-sitter-cli >= 0.26 and GNU make — bootstrap installs both).
--
-- Plain vim cannot use a tree-sitter grammar, so it keeps a generated vim
-- syntax file instead; that lives in the .boot repo under
-- cmux/files/.vim/ and is linked to ~/.vim/.
return {
	{
		"bezhermoso/tree-sitter-ghostty",
		build = "make nvim_install",
		ft = "ghostty",
		-- The plugin's ftdetect must load eagerly, otherwise nothing ever sets
		-- the ghostty filetype that `ft` above waits for.
		init = function()
			vim.filetype.add({
				pattern = {
					[".*/ghostty/config"] = "ghostty",
					[".*/ghostty/themes/[^/]+"] = "ghostty",
				},
			})
		end,
	},
}
