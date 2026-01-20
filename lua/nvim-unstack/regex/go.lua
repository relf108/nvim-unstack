local go = {}

go.name = "Go"
go.regex = vim.regex([[\v^[ \t]*(.+):(\d+) \+0x\x+$]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function go.extract_matches(text)
    local matches = {}
    -- Match Go panic stack trace format
    -- Pattern: whitespace followed by path:line +0xhex
    for match in text:gmatch("[^\n]+") do
        local stripped = match:gsub("^[ \t]+", "")
        local file, line_num = stripped:match("^([^:]+):(%d+) %+0x%x+$")
        if file and line_num then
            table.insert(matches, { file, line_num })
        end
    end
    return matches
end

return go
