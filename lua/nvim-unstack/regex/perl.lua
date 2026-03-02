local perl = {}

perl.name = "Perl"
perl.regex = vim.regex([[\v^[ \t]*at (.+) line (\d+)]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function perl.extract_matches(text)
    local matches = {}
    -- Unwrap line-wrapped content by joining lines that don't start with whitespace
    local unwrapped = text:gsub("\n([^%s])", "%1")

    -- Match Perl stack trace format
    for file, line_num in unwrapped:gmatch("at ([^ ]+) line (%d+)") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return perl
