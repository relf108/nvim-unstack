local main = require("nvim-unstack.main")
local config = require("nvim-unstack.config")
local getVisualSelection = require("nvim-unstack.util.get-visual-selection")

local NvimUnstack = {}

-- Parse a visually selected traceback.
function NvimUnstack.unstack()
    local selection = getVisualSelection()
    local filetype = tostring(vim.bo.filetype)
    local match = require("nvim-unstack.regex.python"):match_str(
        [[File "/opt/anaconda3/envs/icharge-dispatcher/lib/python3.11/site-packages/vpp/enode/db.py", line 30, in data_store]]
    )
    -- for each line in selection if match == 0 (matched) add to a new filtered array
    print(match)
    print(vim.inspect(selection))
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
