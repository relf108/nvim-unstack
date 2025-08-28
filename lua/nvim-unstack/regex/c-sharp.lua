local csharp = {}

csharp.regex = vim.regex([[\v^[ \t]*at .*\(.*\) in (.+):line ([0-9]+) *$]])

function csharp.format_match(line)
    local file = line:match([[ in ([^:]+):line]])
    local line_num = line:match([[:line (%d+)]])
    return { file, line_num }
end

return csharp
