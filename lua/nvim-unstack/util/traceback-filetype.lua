-- TODO @suttont: this is psuedo code but you get the idea
local getVisualSelection = require("nvim-unstack.util.get-visual-selection")

return function()
    local selection = getVisualSelection()
    for _, parser in ipairs(require("nvim-unstack.regex")) do
        local status, _ = pcall(parser.regex:match_str(selection[1]))
        if status then
            return parser
        end
    end
    vim.notify("No traceback parsers found for " .. vim.bo.filetype .. ".", vim.log.levels.ERROR)
end
