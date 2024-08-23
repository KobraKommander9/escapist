local M = {}

M.waiting = false

local settings = require("escapist").config

local recorded_key = nil
local recorded_mode = nil
local has_recorded = false
local bufmodified = nil
local timeout_timer = vim.uv.new_timer()

local termcodes = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function record_key(mode, key)
	if timeout_timer:is_active() then
		timeout_timer:stop()
	end

	M.waiting = true
	recorded_key = key
	recorded_mode = mode
	has_recorded = true
	bufmodified = vim.bo.modified

	timeout_timer:start(settings.timeout, 0, function()
		M.waiting = false
		recorded_key = nil
	end)
end

local undo_keys = {
	i = "<bs><bs>",
	c = "<bs><bs>",
	t = "<bs><bs>",
}

local function execute(mode, action)
	vim.api.nvim_exec_autocmds("User", { pattern = "EscapistExecutePre" })

	local keys = ""
	keys = keys
		.. termcodes((undo_keys[mode] or "") .. (("<cmd>setlocal %smodified<cr>"):format(bufmodified and "" or "no")))

	if type(action) == "string" then
		keys = keys .. termcodes(action)
	else
		keys = keys .. termcodes(action() or "")
	end

	vim.api.nvim_feedkeys(keys, "in", false)

	vim.api.nvim_exec_autocmds("User", { pattern = "EscapistExecutePost" })
end

local function check_key(key)
	local mode = vim.api.nvim_get_mode().mode
	if #mode > 1 then
		mode = mode:sub(1, 1)
	end

	if mode ~= recorded_mode then
		M.waiting = false
		recorded_key = nil
		recorded_mode = nil
	end

	local mappings
	if M.waiting == true then
		mappings = settings.mappings[recorded_mode][recorded_key] or {}
		local action = mappings[key]
		if action then
			M.waiting = false
			execute(recorded_mode, action)
			return
		end
	end

	mappings = settings.mappings[mode] or {}
	if mappings[key] then
		record_key(mode, key)
	end
end

vim.on_key(function(_, typed)
	if typed == "" then
		return
	end

	check_key(typed)

	if has_recorded == false then
		recorded_key = nil
		return
	end
	has_recorded = false
end)

return M
