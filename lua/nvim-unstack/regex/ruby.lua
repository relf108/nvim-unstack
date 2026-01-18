local ruby = {}

ruby.name = "Ruby"
ruby.regex = vim.regex([[\v^[ \t]*from (.+):([0-9]+):in `.*]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function ruby.extract_matches(text)
    local matches = {}
    -- Match Ruby backtrace format
    for file, line_num in text:gmatch("from ([^:]+):(%d+):in") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return ruby
