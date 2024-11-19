-- Get the lines under a visual selection.

return function()
    local s_start = vim.fn.getpos("v")[2]
    local s_end = vim.fn.getpos(".")[2]

    if s_start > s_end then
        return vim.api.nvim_buf_get_lines(0, s_end - 1, s_start, false)
    end

    return vim.api.nvim_buf_get_lines(0, s_start - 1, s_end, false)
end
