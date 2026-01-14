local log = {}

local longest_scope = 15

--- prints only if debug is true.
---
---@param scope string: the scope from where this function is called.
---@param str string: the formatted string.
---@param ... any: the arguments of the formatted string.
---@private
function log.debug(scope, str, ...)
    return log.notify(scope, vim.log.levels.DEBUG, false, str, ...)
end

--- prints only if debug is true.
---
---@param scope string: the scope from where this function is called.
---@param level string: the log level of vim.notify.
---@param verbose boolean: when false, only prints when config.debug is true.
---@param str string: the formatted string.
---@param ... any: the arguments of the formatted string.
---@private
function log.notify(scope, level, verbose, str, ...)
    if not verbose and _G.NvimUnstack.config ~= nil and not _G.NvimUnstack.config.debug then
        return
    end

    local scope_len = string.len(scope)
    if scope_len > longest_scope then
        longest_scope = scope_len
    end

    scope = scope .. string.rep(" ", longest_scope - scope_len)

    vim.notify(
        string.format("[nvim-unstack.nvim@%s] %s", scope, string.format(str, ...)),
        level,
        { title = "nvim-unstack.nvim" }
    )
end

--- analyzes the user provided `setup` parameters and sends a message if they use a deprecated option, then gives the new option to use.
---
---@param options table: the options provided by the user.
---@private
function log.warn_deprecation(options)
    local root_deprecated = {}

    for name, warning in pairs(root_deprecated) do
        if options[name] ~= nil then
            log.notify(
                "deprecated_options",
                vim.log.levels.WARN,
                true,
                string.format("`%s` is now deprecated, use `%s` instead.", name, warning)
            )
        end
    end
end

return log
