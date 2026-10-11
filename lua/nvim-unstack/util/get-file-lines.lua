-- Read file and return table of file lines.

--- @param filepath string
--- @return boolean
local function _file_exists(filepath)
    local f = io.open(filepath, "rb")
    if f then
        f:close()
    end
    return f ~= nil
end

---@param filepath string
---@return table lines
---@private
return function(filepath)
    local expanded_fp = vim.fn.expand(filepath)
    if not _file_exists(expanded_fp) then
        return {}
    end
    local lines = {}
    for line in io.lines(expanded_fp) do
        lines[#lines + 1] = line
    end
    return lines
end
