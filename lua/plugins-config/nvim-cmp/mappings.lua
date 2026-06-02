return {
	common = function(cmp, luasnip)
		return {
			["<CR>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { "i", "c" }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s", "c" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s", "c" }),
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<M-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping(function(fallback)
				local copilot = require("copilot.suggestion")
				if copilot.is_visible() then
					copilot.accept()
				elseif cmp.visible() then
					cmp.close()
					fallback()
				else
					fallback()
				end
			end, { "i", "s", "c" }),
			["<C-[>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.close()
				else
					fallback()
				end
			end, { "i", "s", "c" }),
		}
	end,
}
