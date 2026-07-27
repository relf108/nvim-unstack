local unwrap = require("nvim-unstack.util.unwrap")

local ruby = {}

ruby.name = "Ruby"
ruby.regex = vim.regex([[\v^[ \t]*from (.+):([0-9]+):in `.*]])

-- Match a single logical line like:
--   from /path/to/file.rb:12:in `method'
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    return line:match("^%s*from ([^:]+):(%d+):in")
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function ruby.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return ruby
