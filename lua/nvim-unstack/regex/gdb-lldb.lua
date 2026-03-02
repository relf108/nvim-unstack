local gdb_lldb = {}

gdb_lldb.name = "GDB/LLDB"
gdb_lldb.regex = vim.regex([[\v^[ *]*%(frame )?#\d+:? +0[xX][0-9a-fA-F]+ .+ at (.+):(\d+)]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function gdb_lldb.extract_matches(text)
    local matches = {}
    -- Unwrap line-wrapped content by joining lines that don't start with whitespace
    local unwrapped = text:gsub("\n([^%s])", "%1")

    -- Match GDB/LLDB stack trace format
    for file, line_num in unwrapped:gmatch(" at ([^:]+):(%d+)") do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return gdb_lldb
