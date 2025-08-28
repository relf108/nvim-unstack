local go = {}

go.regex = vim.regex([[\v^[ \t]*(.+):(\d+) \+0x\x+$]])

function go.format_match(line)
    local file = line:match([[^[ \t]*([^:]+):]])
    local line_num = line:match([[:(%d+) ]])
    return { file, line_num }
end

return go
