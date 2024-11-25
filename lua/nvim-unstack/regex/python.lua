local python = {}

python.regex = vim.regex([[\v^ *File "([^"]+)", line ([0-9]+).*]])

---@param line string: language specific func to jump to traceback line.
---@return table
function python.format_match(line)
    local file = line:match([["([^"]+)",]])
    local line_num = line:match([[([0-9]+),]])
    return { file, line_num }
end

return python
