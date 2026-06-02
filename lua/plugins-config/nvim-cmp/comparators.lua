local cmp = require("cmp")
local compare = cmp.config.compare -- helper that exposes all built-ins
return {
	-- compare.kind, -- functions > variables > snippets … (optional)
	compare.score, -- LSP / source fuzzy score
	function(entry1, entry2)
		local kind1 = entry1:get_kind()
		local kind2 = entry2:get_kind()

		-- See :h cmp.lsp.CompletionItemKind
		local kind_priority = {
			-- highest priority group: what you usually want inside {...} or arg lists
			[cmp.lsp.CompletionItemKind.Field] = 0,
			[cmp.lsp.CompletionItemKind.Property] = 0,
			[cmp.lsp.CompletionItemKind.Variable] = 1,
			[cmp.lsp.CompletionItemKind.TypeParameter] = 1,

			-- mid: functions/methods (possible value completions)
			[cmp.lsp.CompletionItemKind.Function] = 2,
			[cmp.lsp.CompletionItemKind.Method] = 2,

			-- low: keywords, snippets, text, etc.
			[cmp.lsp.CompletionItemKind.Keyword] = 3,
			[cmp.lsp.CompletionItemKind.Snippet] = 4,
			[cmp.lsp.CompletionItemKind.Text] = 5,
		}

		local p1 = kind_priority[kind1] or 10
		local p2 = kind_priority[kind2] or 10

		if p1 < p2 then
			return true
		elseif p1 > p2 then
			return false
		end
		-- if same priority, fall through to the next comparator
	end,
	compare.exact, -- exact prefix wins
	compare.offset, -- start-of-word matches win
	compare.recently_used, -- what you confirmed before
	compare.locality, -- identifiers closer to the cursor
	compare.sort_text, -- fallback to server-provided sortText
	compare.length, -- shorter names win if still tied
	compare.order, -- final deterministic tie-break
}
