local gdb_lldb = {}

gdb_lldb.name = "GDB/LLDB"
gdb_lldb.regex = vim.regex([[\v^[ *]*%(frame )?#\d+:? +0[xX][0-9a-fA-F]+ .+ at (.+):(\d+)]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function gdb_lldb.extract_matches(text)
    local matches = {}
    -- Match GDB/LLDB stack trace format
    for file, line_num in text:gmatch(" at ([^:]+):(%d+)") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return gdb_lldb
