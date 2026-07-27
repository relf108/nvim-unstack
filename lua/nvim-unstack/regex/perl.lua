local unwrap = require("nvim-unstack.util.unwrap")

local perl = {}

perl.name = "Perl"
perl.regex = vim.regex([[\v^[ \t]*at (.+) line (\d+)]])

-- Match a single logical line like:
--   at /path/to/script.pl line 12.
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    return line:match("at ([^%s]+) line (%d+)")
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function perl.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return perl
