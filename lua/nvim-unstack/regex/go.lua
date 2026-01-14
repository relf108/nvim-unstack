local go = {}

go.regex = vim.regex([[\v^[ \t]*(.+):(\d+) \+0x\x+$]])

---@param line string
---@return table
---@private
function go.format_match(line)
    -- Strip leading whitespace first
    line = line:gsub("^[ \t]+", "")
    local file = line:match("([^:]+)")
    local line_num = line:match(":(%d+)")
    return { file, line_num }
end

return go
