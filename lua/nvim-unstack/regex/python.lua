local python = {}

python.name = "Python"
python.regex = vim.regex([[\v^ *File "([^"]+)"]])

---@param line string: language specific func to jump to traceback line.
---@param lines table: all lines for multiline parsing
---@param index number: current line index
---@return table
---@private
function python.format_match(line, lines, index)
    local file = line:match([["([^"]+)"]])
    local line_num = line:match([[line ([0-9]+)]])

    -- If line number not found on current line, check next line
    if not line_num and lines and index and lines[index + 1] then
        line_num = lines[index + 1]:match([[e ([0-9]+)]])
    end

    return { file, line_num }
end

return python
