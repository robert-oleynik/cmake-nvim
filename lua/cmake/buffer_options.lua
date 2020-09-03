local M = {}

M.global_set = function(options)
	for name, value in pairs(options) do
		vim.api.nvim_set_option(name, value)
	end
end

M.buffer_set = function(bufnr,options)
	for name, value in pairs(options) do
		vim.api.nvim_buf_set_option(bufnr, name, value)
	end
end

M.win_set = function(winnr,options)
	for name, value in pairs(options) do
		vim.api.nvim_win_set_option(winnr, name, value)
	end
end

return M
