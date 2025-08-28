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

    -- Layout configuration
    layout = "tab", -- "vsplit", "split", "tab", "floating"

    -- Key mapping for visual selection unstacking
    mapkey = "<leader>s",

    -- Show signs on lines from stack trace
    showsigns = true,

    -- Vertical alignment for splits
    vertical_alignment = "topleft", -- "topleft", "topright", "bottomleft", "bottomright"
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

    local valid_layouts = { "vsplit", "split", "tab", "floating" }
    assert(
        vim.tbl_contains(valid_layouts, NvimUnstack.options.layout),
        "`layout` must be one of: " .. table.concat(valid_layouts, ", ")
    )

    assert(type(NvimUnstack.options.mapkey) == "string", "`mapkey` must be a string.")

    assert(
        type(NvimUnstack.options.showsigns) == "boolean",
        "`showsigns` must be a boolean (`true` or `false`)."
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
