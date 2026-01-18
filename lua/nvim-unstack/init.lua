local config = require("nvim-unstack.config")
local getVisualSelection = require("nvim-unstack.util.get-visual-selection")
local openMatches = require("nvim-unstack.util.open-matches")
local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")

local NvimUnstack = {}

-- Parse a traceback from provided lines.
local function parse_traceback_lines(lines, callback)
    local status, _ = pcall(function()
        tracebackFiletype(lines, function(parser)
            local text = table.concat(lines, "\n")
            local matches = parser.extract_matches(text)
            callback(matches)
        end)
    end)

    if not status then
        vim.notify("No traceback parsers found.", vim.log.levels.ERROR)
        callback({})
    end
end

-- Parse a visually selected traceback.
function NvimUnstack.unstack()
    local selection = getVisualSelection()
    parse_traceback_lines(selection, function(matches)
        openMatches(matches)
    end)
end

-- Parse traceback from system clipboard
function NvimUnstack.unstack_from_clipboard()
    local clipboard_content = vim.fn.getreg("+")
    if not clipboard_content or clipboard_content == "" then
        vim.notify("Clipboard is empty.", vim.log.levels.WARN)
        return
    end

    local lines = vim.split(clipboard_content, "\n")
    parse_traceback_lines(lines, function(matches)
        openMatches(matches)
    end)
end

-- Parse traceback from tmux paste buffer
function NvimUnstack.unstack_from_tmux()
    local tmux_content = vim.fn.system("tmux show-buffer 2>/dev/null")
    if vim.v.shell_error ~= 0 or not tmux_content or tmux_content == "" then
        vim.notify("No tmux buffer found or tmux not available.", vim.log.levels.WARN)
        return
    end

    local lines = vim.split(tmux_content, "\n")
    parse_traceback_lines(lines, function(matches)
        openMatches(matches)
    end)
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

    -- Set up keymap using configured mapkey
    if type(_G.NvimUnstack.config.mapkey) == "string" then
        vim.keymap.set("v", _G.NvimUnstack.config.mapkey, function()
            require("nvim-unstack").unstack()
        end, { desc = "Unstack visual selection" })
    end
end

_G.NvimUnstack = NvimUnstack

return _G.NvimUnstack
