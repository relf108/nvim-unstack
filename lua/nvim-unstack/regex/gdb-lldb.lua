local gdb_lldb = {}

gdb_lldb.regex = vim.regex([[\v^[ *]*%(frame )?#\d+:? +0[xX][0-9a-fA-F]+ .+ at (.+):(\d+)]])

---@param line string
---@return table
---@private
function gdb_lldb.format_match(line)
    local file = line:match([[ at ([^:]+):]])
    local line_num = line:match([[:(%d+)$]])
    return { file, line_num }
end

return gdb_lldb
