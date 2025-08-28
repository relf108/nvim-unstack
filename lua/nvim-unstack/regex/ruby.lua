local ruby = {}

ruby.regex = vim.regex([[\v^[ \t]*from (.+):([0-9]+):in `.*]])

function ruby.format_match(line)
    local file = line:match([[from ([^:]+):]])
    local line_num = line:match([[:(%d+):in]])
    return { file, line_num }
end

return ruby
