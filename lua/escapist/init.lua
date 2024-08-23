local M = {}

local defaults = {
	keys = { "jk" },
	timeout = vim.o.timeoutlen,
}

local function validate_keys(keys)
	assert(type(keys) == "table", "keys must be a table")

	for _, mapping in ipairs(keys) do
		assert(type(mapping) == "string" or type(mapping) == "table", "keys must be a string or table")

		-- each key can specify an action and mode(s)
		if type(mapping) == "string" then
			-- replace all multibyte chars to `A` char
			local length = #vim.fn.substitute(mapping, ".", "A", "g")
			assert(length == 2, "keys must be 2 characters long")
		else
			assert(#mapping >= 1, "keys must have at least 1 key")
			for key, v in mapping do
				if key == "action" then
					assert(type(v) == "string" or type(v) == "function", "action must be a string or function")
				elseif key == "mode" then
					assert(type(v) == "string" or type(v) == "table", "mode must be a string or table")
				end
			end
		end
	end
end

local function get_keys(keys)
	local mappings = {
		n = {},
		i = {},
		c = {},
		t = {},
		v = {},
		s = {},
	}

	for _, mapping in ipairs(keys) do
		local first_key, second_key
		if type(mapping) == "string" then
			first_key = mapping:sub(1, 1)
			second_key = mapping:sub(2, 2)
		else
			first_key = mapping[1]:sub(1, 1)
			second_key = mapping[1]:sub(2, 2)
		end

		local modes = {
			n = {
				[first_key] = { [second_key] = "<Esc>" },
			},
			i = {
				[first_key] = { [second_key] = "<Esc>" },
			},
			c = {
				[first_key] = { [second_key] = "<Esc>" },
			},
			t = {
				[first_key] = { [second_key] = "<C-\\><C-n>" },
			},
			v = {
				[first_key] = { [second_key] = "<Esc>" },
			},
			s = {
				[first_key] = { [second_key] = "<Esc>" },
			},
		}

		if type(mapping) == "table" then
			local mode = mapping.mode or { "n", "i", "c", "t", "v", "s" }
			if type(mode) == "string" then
				mode = { mode }
			end

			for _, m in ipairs(mode) do
				if mapping.action then
					modes[m][first_key][second_key] = mapping.action
				end
			end
		end

		mappings = vim.tbl_deep_extend("force", mappings, modes)
	end

	return mappings
end

M.config = {}

function M.setup(opts)
	local options = vim.tbl_deep_extend("force", defaults, opts or {})

	local ok, msg = pcall(validate_keys, options.keys)
	if not ok then
		vim.notify("Error(keys): " .. msg, vim.log.levels.ERROR)
		return
	end

	M.config = {
		timeout = options.timeout,
		mappings = get_keys(options.keys),
	}
end

setmetatable(M, {
	__index = function(m, key)
		if key == "config" then
			return m.config
		end

		m[key] = require("escapist." .. key)
		return m[key]
	end,
})

return M
