local nodejs = {}

nodejs.regex = vim.regex([[\v^ +at .+\((.+):(\d+):\d+\)$]])

---@param line string
---@return table
---@private
function nodejs.format_match(line)
    local file = line:match([[%(([^:]+):]])
    local line_num = line:match([[:(%d+):]])
    return { file, line_num }
end

return nodejs
