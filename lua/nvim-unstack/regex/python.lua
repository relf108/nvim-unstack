local unwrap = require("nvim-unstack.util.unwrap")

local python = {}

python.name = "Python"
python.regex = vim.regex([[\v^ *File "([^"]+)"]])

-- Match a single logical line like:
--   File "/app/main.py", line 10, in <module>
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    return line:match('^%s*File "([^"]+)",%s*line%s*(%d+)')
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function python.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return python
