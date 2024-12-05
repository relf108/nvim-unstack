-- Determine associated filetype of stacktrace.
--
-- TODO @suttont: this might actually be working but it won't be clear until all the parsers match the format defined in python.lua

local function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "' .. directory .. '"')
    if not pfile then
        return {}
    end
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

---@param selection table
return function(selection)
    print(vim.inspect(selection))
    local lang = nil
    local parser = nil
    for _, file in ipairs(scandir("lua/nvim-unstack/regex")) do
        local find = string.find(file, [[.lua]])
        if not find then
            goto continue
        end

        lang = string.sub(file, 1, find - 1)
        print(lang)
        parser = require("nvim-unstack.regex." .. lang)
        print(vim.inspect(parser))
        for _, line in ipairs(selection) do
            print(vim.inspect(parser))
            if parser.regex:match_str(line) == 0 then
                return parser
            end
        end

        ::continue::
    end
    error("No traceback parsers found.")
end
