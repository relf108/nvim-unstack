-- Determine associated filetype of stacktrace.

---@param selection table
return function(selection)
    -- List of available parsers
    local parsers = {
        "python",
        "nodejs",
        "ruby",
        "go",
        "c-sharp",
        "perl",
        "gdb-lldb",
    }

    for _, parser_name in ipairs(parsers) do
        local ok, parser = pcall(require, "nvim-unstack.regex." .. parser_name)
        if ok and parser and parser.regex then
            for _, line in ipairs(selection) do
                if parser.regex:match_str(line) == 0 then
                    return parser
                end
            end
        end
    end

    error("No traceback parsers found.")
end
