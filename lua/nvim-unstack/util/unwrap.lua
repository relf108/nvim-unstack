-- Shared helper for parsing tracebacks that may have been hard-wrapped by
-- the terminal.
local unwrap = {}

-- Extract { file, line_num } matches from traceback text, tolerating
-- terminal hard-wrapping.
--
-- Terminals hard-wrap long lines at the terminal width. That width is
-- inferred as the longest line in the selection: any wrapped segment is
-- exactly terminal-width chars, and most runners pad header/separator lines
-- to the full width, so this locks onto the right value at any terminal
-- size.
--
-- Matching runs in two passes:
--   1. Logical lines (wrap-rejoined): a line exactly `width` chars long
--      followed by a line starting with a non-space char is treated as
--      hard-wrapped and joined with its continuation. Recovers locations
--      whose paths were split across lines.
--   2. Raw lines: rescues locations falsely glued to a preceding full-width
--      line (e.g. a ==== header exactly `width` chars long). Candidates
--      whose path is just the tail of an already-matched wrapped path (the
--      continuation segment of a genuine wrap) are skipped.
-- Results are deduplicated on file:line.
--
---@param text string entire traceback as a single string
---@param match_line fun(line: string): string|nil, string|nil matcher returning file, line_num for a single logical line
---@return table matches array of { file, line_num }
function unwrap.extract_matches(text, match_line)
    local raw_lines = vim.split(text, "\n", { plain = true })

    local width = 0
    for _, line in ipairs(raw_lines) do
        if #line > width then
            width = #line
        end
    end

    local logical_lines = {}
    local acc = ""
    for i, line in ipairs(raw_lines) do
        acc = acc .. line
        local next_line = raw_lines[i + 1]
        if not (#line == width and next_line and next_line:match("^%S")) then
            table.insert(logical_lines, acc)
            acc = ""
        end
    end

    local matches = {}
    local seen = {}
    local function add(file, line_num)
        local key = file .. ":" .. line_num
        if not seen[key] then
            seen[key] = true
            table.insert(matches, { file, line_num })
        end
    end

    -- Pass 1: unwrapped logical lines
    for _, line in ipairs(logical_lines) do
        local file, line_num = match_line(line)
        if file then
            add(file, line_num)
        end
    end

    -- Pass 2: raw lines, skipping wrap-continuation partials
    for _, line in ipairs(raw_lines) do
        local file, line_num = match_line(line)
        if file then
            local partial = false
            for _, m in ipairs(matches) do
                if m[2] == line_num and #m[1] > #file and m[1]:sub(-#file) == file then
                    partial = true
                    break
                end
            end
            if not partial then
                add(file, line_num)
            end
        end
    end

    return matches
end

return unwrap
