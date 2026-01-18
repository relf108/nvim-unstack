local perl = {}

perl.name = "Perl"
perl.regex = vim.regex([[\v^[ \t]*at (.+) line (\d+)]])

---@param line string
---@return table
---@private
function perl.format_match(line)
    local file = line:match([[at ([^ ]+) line]])
    local line_num = line:match([[line (%d+)]])
    return { file, line_num }
end

return perl
