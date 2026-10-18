-- Option-as-Alt fallback for terminals that do not send Option as Alt/Meta.
--
-- When a terminal treats macOS Option as the layout's compose modifier instead
-- of as Alt, Option+b never arrives as <M-b>: it arrives as the character the
-- active layout composes for it ("∫" on the US / "ABC" layout). Each of those
-- characters is aliased here to its <M-…> equivalent, so every <M-…> mapping in
-- this config answers to both forms, in whichever terminal.
--
-- Nothing is shadowed. The alias only redirects when the current mode really
-- has an <M-…> mapping for that key; otherwise the character is inserted as
-- typed, so ø, ç, ≥ … can still be entered normally.
--
-- Option+e, +i, +n, +u and +` are dead keys — they emit nothing until the next
-- keypress — so <M-e>, <M-i>, <M-n> and <M-u> have no composed form and need a
-- terminal that sends a real Alt. <M-CR> likewise: Option+Return composes
-- nothing.
--
-- The table is the macOS US ("ABC") layout, generated from the live layout via
-- UCKeyTranslate (see macos/option-key-chars.py in the .boot repo). Regenerate
-- it if the active input source changes.

-- stylua: ignore
local composed = {
	-- letters (e, i, n, u are dead keys — absent by necessity)
	["å"] = "a", ["∫"] = "b", ["ç"] = "c", ["∂"] = "d", ["ƒ"] = "f",
	["©"] = "g", ["˙"] = "h", ["∆"] = "j", ["˚"] = "k", ["¬"] = "l",
	["µ"] = "m", ["ø"] = "o", ["π"] = "p", ["œ"] = "q", ["®"] = "r",
	["ß"] = "s", ["†"] = "t", ["√"] = "v", ["∑"] = "w", ["≈"] = "x",
	["¥"] = "y", ["Ω"] = "z",
	-- digits
	["¡"] = "1", ["™"] = "2", ["£"] = "3", ["¢"] = "4", ["∞"] = "5",
	["§"] = "6", ["¶"] = "7", ["•"] = "8", ["ª"] = "9", ["º"] = "0",
	-- punctuation
	["–"] = "-", ["≠"] = "=", ["“"] = "[", ["‘"] = "]", ["«"] = "\\",
	["…"] = ";", ["æ"] = "'", ["≤"] = ",", ["≥"] = ".", ["÷"] = "/",
	["\194\160"] = "Space", -- U+00A0 no-break space, what Option+Space composes
	-- shifted punctuation this config maps
	["”"] = "{", ["’"] = "}", ["‡"] = "&",
}

local modes = { "n", "x", "s", "o", "i", "c", "t" }

return function()
	for char, key in pairs(composed) do
		local alt = "<M-" .. key .. ">"
		local keys = vim.api.nvim_replace_termcodes(alt, true, true, true)
		for _, mode in ipairs(modes) do
			vim.keymap.set(mode, char, function()
				if vim.fn.maparg(alt, mode) ~= "" then
					-- Hand over to the <M-…> mapping, keeping any count typed
					-- in front of it.
					-- "i" puts them at the head of the typeahead, ahead of
					-- whatever else is already queued; "m" = remap, so the
					-- <M-…> mapping is honoured.
					local count = vim.v.count > 0 and tostring(vim.v.count) or ""
					vim.api.nvim_feedkeys(count .. keys, "mi", false)
				else
					-- No Alt mapping here: insert the character as typed.
					vim.api.nvim_feedkeys(char, "ni", true)
				end
			end, { desc = "Option+" .. key .. " → " .. alt })
		end
	end
end
