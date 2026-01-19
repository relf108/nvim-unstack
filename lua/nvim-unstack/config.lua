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

    -- Exclude file paths matching these patterns from stack traces
    -- Set to false to disable filtering, or provide a table of patterns to match
    -- Patterns are matched against the absolute file path
    exclude_patterns = {
        "node_modules", -- JavaScript/TypeScript dependencies
        ".venv", -- Python virtual environment
        "venv", -- Python virtual environment (alternate name)
        "site%-packages", -- Python installed packages
        "dist%-packages", -- Python system packages
        "/usr/", -- System libraries (Unix)
        "/lib/", -- System libraries
        "%.cargo/", -- Rust dependencies
        "vendor/", -- Ruby/Go dependencies
    },

    -- Return first parser match
    -- Disable to get popup for available parsers (useful for python and pytest)
    usefirstparser = true,
}

---@private
local defaults = vim.deepcopy(NvimUnstack.options)

--- Defaults NvimUnstack options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |NvimUnstack.options|.
---
---@private
function NvimUnstack.defaults(options)
    NvimUnstack.options = vim.tbl_deep_extend("keep", options or {}, defaults or {})

    -- let your user know that they provided a wrong value, this is reported when your plugin is executed.
    assert(
        type(NvimUnstack.options.debug) == "boolean",
        "`debug` must be a boolean (`true` or `false`)."
    )

    local valid_layouts = { "vsplit", "split", "tab", "floating", "quickfix_list" }
    assert(
        vim.tbl_contains(valid_layouts, NvimUnstack.options.layout),
        "`layout` must be one of: " .. table.concat(valid_layouts, ", ")
    )

    assert(
        type(NvimUnstack.options.mapkey) == "string"
            or type(NvimUnstack.options.mapkey) == "boolean",
        "`mapkey` must be a string or boolean."
    )

    assert(
        type(NvimUnstack.options.showsigns) == "boolean",
        "`showsigns` must be a boolean (`true` or `false`)."
    )

    assert(
        type(NvimUnstack.options.usefirstparser) == "boolean",
        "`usefirstparser` must be a boolean (`true` or `false`)."
    )

    assert(
        type(NvimUnstack.options.exclude_patterns) == "table"
            or NvimUnstack.options.exclude_patterns == false,
        "`exclude_patterns` must be a table of patterns or false to disable."
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
