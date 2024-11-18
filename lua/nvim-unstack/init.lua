local main = require("nvim-unstack.main")
local config = require("nvim-unstack.config")

local NvimUnstack = {}

--- Toggle the plugin by calling the `enable`/`disable` methods respectively.
function NvimUnstack.toggle()
    if _G.NvimUnstack.config == nil then
        _G.NvimUnstack.config = config.options
    end

    vim.notify("NvimUnstack toggled")
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
