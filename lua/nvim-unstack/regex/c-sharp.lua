local unwrap = require("nvim-unstack.util.unwrap")

local csharp = {}

csharp.name = "C#"
csharp.regex = vim.regex([[\v^[ \t]*at .*\(.*\) in (.+):line ([0-9]+) *$]])

-- Match a single logical line like:
--   at MyApp.Program.Main(String[] args) in C:\app\Program.cs:line 12
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    -- Greedy capture up to the final ":line N" so Windows drive-letter
    -- colons (C:\...) stay part of the path
    return line:match(" in (.+):line (%d+)%s*$")
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function csharp.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return csharp
