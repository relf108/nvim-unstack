-- Determine associated filetype of stacktrace.

---@param selection table
---@param callback function Callback to receive the parser
---@return nil
---@private
return function(selection, callback)
    -- List of available parsers
    local parsers = {
        "python",
        "pytest",
        "nodejs",
        "ruby",
        "go",
        "c-sharp",
        "perl",
        "gdb-lldb",
    }

    -- validate parsers
    local validated_parsers = {}
    for _, parser_name in ipairs(parsers) do
        local ok, parser = pcall(require, "nvim-unstack.regex." .. parser_name)
        if ok and parser and parser.regex then
            table.insert(validated_parsers, parser)
        end
    end

    -- Get matching parsers
    local matched_parsers = {}
    for _, v_parser in ipairs(validated_parsers) do
        for _, line in ipairs(selection) do
            if v_parser.regex:match_str(line) == 0 then
                if _G.NvimUnstack.config.use_first_parser then
                    callback(v_parser)
                    return
                end

                table.insert(matched_parsers, v_parser)
                break
            end
        end
    end

    if #matched_parsers == 0 then
        error("No traceback parsers found.")
    end

    if #matched_parsers == 1 then
        callback(matched_parsers[1])
        return
    end

    vim.ui.select(matched_parsers, {
        prompt = "Select a parser:",
        format_item = function(parser)
            return parser.name
        end,
    }, function(_, idx)
        if idx then
            callback(matched_parsers[idx])
        else
            -- User cancelled, use first parser as fallback
            callback(matched_parsers[1])
        end
    end)
end
