local csharp = {}

csharp.name = "C#"
csharp.regex = vim.regex([[\v^[ \t]*at .*\(.*\) in (.+):line ([0-9]+) *$]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function csharp.extract_matches(text)
    local matches = {}
    -- Match C# stack trace format
    for file, line_num in text:gmatch(" in ([^:]+):line (%d+)") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return csharp
