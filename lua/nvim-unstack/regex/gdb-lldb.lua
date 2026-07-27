local unwrap = require("nvim-unstack.util.unwrap")

local gdb_lldb = {}

gdb_lldb.name = "GDB/LLDB"
gdb_lldb.regex = vim.regex([[\v^[ *]*%(frame )?#\d+:? +0[xX][0-9a-fA-F]+ .+ at (.+):(\d+)]])

-- Match a single logical line like:
--   #0  0x0000555555555131 in main () at main.c:5
--   frame #1: 0x0000000100003f4c app`main at main.c:12
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    return line:match(" at ([^:%s]+):(%d+)")
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function gdb_lldb.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return gdb_lldb
