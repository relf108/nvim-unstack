local nodejs = {}

nodejs.regex = vim.regex([[\v^ +at .+\((.+):(\d+):\d+\)$]])

function nodejs.format_match(line)
    local file = line:match([[\(([^:]+):]])
    local line_num = line:match([[:(%d+):]])
    return { file, line_num }
end

return nodejs
