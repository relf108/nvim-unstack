local ruby = {}

ruby.name = "Ruby"
ruby.regex = vim.regex([[\v^[ \t]*from (.+):([0-9]+):in `.*]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function ruby.extract_matches(text)
    local matches = {}
    -- Unwrap line-wrapped content by joining lines that don't start with whitespace
    local unwrapped = text:gsub("\n([^%s])", "%1")

    -- Match Ruby backtrace format
    for file, line_num in unwrapped:gmatch("from ([^:]+):(%d+):in") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return ruby
