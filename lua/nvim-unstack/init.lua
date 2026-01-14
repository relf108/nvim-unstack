local config = require("nvim-unstack.config")
local getVisualSelection = require("nvim-unstack.util.get-visual-selection")
local openMatches = require("nvim-unstack.util.open-matches")
local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")

local NvimUnstack = {}

-- Parse a traceback from provided lines.
local function parse_traceback_lines(lines)
    local matches = {}

    local status, parser = pcall(function()
        return tracebackFiletype(lines)
    end)

    if not status then
        vim.notify("No traceback parsers found.", vim.log.levels.ERROR)
        return {}
    end

    for i, line in ipairs(lines) do
        if parser.regex:match_str(line) == 0 then
            table.insert(matches, parser.format_match(line, lines, i))
        end
    end

    return matches
end

-- Parse a visually selected traceback.
function NvimUnstack.unstack()
    local selection = getVisualSelection()
    local matches = parse_traceback_lines(selection)
    openMatches(matches)
end

-- Parse traceback from system clipboard
function NvimUnstack.unstack_from_clipboard()
    local clipboard_content = vim.fn.getreg("+")
    if not clipboard_content or clipboard_content == "" then
        vim.notify("Clipboard is empty.", vim.log.levels.WARN)
        return
    end

    local lines = vim.split(clipboard_content, "\n")
    local matches = parse_traceback_lines(lines)
    openMatches(matches)
end

-- Parse traceback from tmux paste buffer
function NvimUnstack.unstack_from_tmux()
    local tmux_content = vim.fn.system("tmux show-buffer 2>/dev/null")
    if vim.v.shell_error ~= 0 or not tmux_content or tmux_content == "" then
        vim.notify("No tmux buffer found or tmux not available.", vim.log.levels.WARN)
        return
    end

    local lines = vim.split(tmux_content, "\n")
    local matches = parse_traceback_lines(lines)
    openMatches(matches)
end

-- setup NvimUnstack options and merge them with user provided ones.
function NvimUnstack.setup(opts)
    _G.NvimUnstack.config = config.setup(opts)

    -- Define signs for highlighting stack trace lines
    if _G.NvimUnstack.config.showsigns then
        vim.fn.sign_define("UnstackLine", {
            text = ">>",
            texthl = "Search",
            linehl = "CursorLine",
        })
    end
end

_G.NvimUnstack = NvimUnstack

return _G.NvimUnstack
