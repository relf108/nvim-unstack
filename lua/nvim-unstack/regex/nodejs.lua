local unwrap = require("nvim-unstack.util.unwrap")

local nodejs = {}

nodejs.name = "Node.js"
nodejs.regex = vim.regex([[\v^ +at .+\((.+):(\d+):\d+\)$]])

-- Match a single logical line like:
--   at processData (/home/user/project/src/processor.js:15:10)
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    local file, line_num = line:match("^%s+at [^(]+%(([^:]+):(%d+):%d+%)")
    return file, line_num
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function nodejs.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return nodejs
