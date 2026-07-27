local unwrap = require("nvim-unstack.util.unwrap")

local go = {}

go.name = "Go"
go.regex = vim.regex([[\v^[ \t]*(.+):(\d+) \+0x\x+$]])

-- Match a single logical line like:
--   /app/main.go:42 +0x1a
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    return line:match("^%s*([^:%s]+):(%d+) %+0x%x+%s*$")
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function go.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return go
