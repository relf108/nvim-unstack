local main = require("nvim-unstack.main")
local config = require("nvim-unstack.config")
local getVisualSelection = require("nvim-unstack.util.get-visual-selection")
local openMatches = require("nvim-unstack.util.open-matches")

local NvimUnstack = {}

-- Parse a visually selected traceback.
function NvimUnstack.unstack()
    local matches = {}

    local status, parser = pcall(function()
        return require("nvim-unstack.regex." .. vim.bo.filetype)
    end)

    if not status then
        vim.notify(
            "No traceback parsers found for " .. vim.bo.filetype .. ".",
            vim.log.levels.ERROR
        )
        return
    end

    for _, line in ipairs(getVisualSelection()) do
        if parser.regex:match_str(line) == 0 then
            table.insert(matches, parser.format_match(line))
        end
    end
    openMatches(matches)
end

--- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function NvimUnstack.toggle()
    if _G.NvimUnstack.config == nil then
        _G.NvimUnstack.config = config.options
    end

    main.toggle("public_api_toggle")
end

--- Initializes the plugin, sets event listeners and internal state.
function NvimUnstack.enable(scope)
    if _G.NvimUnstack.config == nil then
        _G.NvimUnstack.config = config.options
    end

    main.toggle(scope or "public_api_enable")
end

--- Disables the plugin, clear highlight groups and autocmds, closes side buffers and resets the internal state.
function NvimUnstack.disable()
    main.toggle("public_api_disable")
end

-- setup NvimUnstack options and merge them with user provided ones.
function NvimUnstack.setup(opts)
    _G.NvimUnstack.config = config.setup(opts)
end

_G.NvimUnstack = NvimUnstack

return _G.NvimUnstack
