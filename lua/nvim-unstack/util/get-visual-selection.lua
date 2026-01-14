-- Get the lines under a visual selection.

---@return table lines
---@private
return function()
    local s_start = vim.fn.getpos("v")[2]
    local s_end = vim.fn.getpos(".")[2]
    local first = math.min(s_start, s_end)
    local last = math.max(s_start, s_end)

    return vim.api.nvim_buf_get_lines(0, first - 1, last, false)
end
