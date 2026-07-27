local pytest = {}

-- Pytest traceback lines look like:
-- tests/test_example.py:42: AssertionError
-- tests/test_example.py:15:
-- src/calculator.py:8: ZeroDivisionError
-- FAILED tests/test_math.py::test_division - ZeroDivisionError
-- ERROR tests/unit/test_utils.py
pytest.name = "Pytest"
pytest.regex = vim.regex([[\v(^\s*\S+\.py:\d+:|^(FAILED|ERROR) \S+\.py)]])

-- Match a single logical line against pytest location/summary patterns.
---@param line string
---@return string|nil file
---@return string|nil line_num
local function match_line(line)
    -- Location lines like: tests/test_example.py:42: AssertionError
    local file, line_num = line:match("^%s*([^%s:]+%.py):(%d+):")
    if file then
        return file, line_num
    end

    -- Summary lines like:
    --   FAILED tests/test_math.py::test_division - ZeroDivisionError
    --   ERROR tests/unit/test_utils.py
    -- These carry no line number; default to line 1 so there is still a
    -- deterministic jump target.
    file = line:match("^FAILED%s+([^%s:]+%.py)") or line:match("^ERROR%s+([^%s:]+%.py)")
    if file then
        return file, "1"
    end

    return nil, nil
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function pytest.extract_matches(text)
    local raw_lines = vim.split(text, "\n", { plain = true })

    -- Terminals hard-wrap long lines at the terminal width. Infer that width
    -- as the longest line in the selection: any wrapped segment is exactly
    -- terminal-width chars, and pytest pads its ==== header lines to the full
    -- width, so this locks onto the right value at any terminal size.
    local width = 0
    for _, line in ipairs(raw_lines) do
        if #line > width then
            width = #line
        end
    end

    -- Rebuild logical lines: a line exactly `width` chars long followed by a
    -- line starting with a non-space char is treated as hard-wrapped and
    -- joined with its continuation.
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

    -- Pass 1: unwrapped logical lines. Recovers locations whose paths were
    -- split across lines by terminal wrapping.
    for _, line in ipairs(logical_lines) do
        local file, line_num = match_line(line)
        if file then
            add(file, line_num)
        end
    end

    -- Pass 2: raw lines. Rescues locations falsely glued to a preceding
    -- full-width line (e.g. a ==== header exactly `width` chars long).
    -- Skip candidates whose path is just the tail of an already-matched
    -- wrapped path (the continuation segment of a genuine wrap).
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

return pytest
