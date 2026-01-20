local nodejs = {}

nodejs.name = "Node.js"
nodejs.regex = vim.regex([[\v^ +at .+\((.+):(\d+):\d+\)$]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function nodejs.extract_matches(text)
    local matches = {}
    -- Match Node.js stack trace format
    for file, line_num in text:gmatch("%s+at [^(]+%(([^:]+):(%d+):%d+%)") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return nodejs
