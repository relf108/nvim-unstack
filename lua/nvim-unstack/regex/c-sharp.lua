local csharp = {}

csharp.name = "C#"
csharp.regex = vim.regex([[\v^[ \t]*at .*\(.*\) in (.+):line ([0-9]+) *$]])

---@param line string
---@return table
---@private
function csharp.format_match(line)
    local file = line:match([[ in ([^:]+):line]])
    local line_num = line:match([[:line (%d+)]])
    return { file, line_num }
end

return csharp
