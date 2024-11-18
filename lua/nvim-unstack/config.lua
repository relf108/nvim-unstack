local log = require("nvim-unstack.util.log")

local NvimUnstack = {}

--- NvimUnstack configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
NvimUnstack.options = {
    -- Prints useful logs about what event are triggered, and reasons actions are executed.
    debug = false,
}

---@private
local defaults = vim.deepcopy(NvimUnstack.options)

--- Defaults NvimUnstack options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |NvimUnstack.options|.
---
---@private
function NvimUnstack.defaults(options)
    NvimUnstack.options = vim.deepcopy(vim.tbl_deep_extend("keep", options or {}, defaults or {}))

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(
        type(NvimUnstack.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    return NvimUnstack.options
end

--- Define your nvim-unstack setup.
---
---@param options table Module config table. See |NvimUnstack.options|.
---
---@usage `require("nvim-unstack").setup()` (add `{}` with your |NvimUnstack.options| table)
function NvimUnstack.setup(options)
    NvimUnstack.options = NvimUnstack.defaults(options or {})

    log.warn_deprecation(NvimUnstack.options)

    return NvimUnstack.options
end

return NvimUnstack
