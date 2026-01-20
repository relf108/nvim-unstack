local perl = {}

perl.name = "Perl"
perl.regex = vim.regex([[\v^[ \t]*at (.+) line (\d+)]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function perl.extract_matches(text)
    local matches = {}
    -- Match Perl stack trace format
    for file, line_num in text:gmatch("at ([^ ]+) line (%d+)") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return perl
