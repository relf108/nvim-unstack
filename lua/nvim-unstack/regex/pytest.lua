local pytest = {}

-- Pytest traceback lines look like:
-- tests/test_example.py:42: AssertionError
-- tests/test_example.py:15:
-- src/calculator.py:8: ZeroDivisionError
-- FAILED tests/test_math.py::test_division - ZeroDivisionError
pytest.regex = vim.regex([[\v(^\s*\S+\.py:\d+:|^FAILED \S+\.py)]])

---@param line string: language specific func to jump to traceback line.
---@param lines table: all lines for multiline parsing
---@param index number: current line index
---@return table
function pytest.format_match(line, lines, index)
    -- Match patterns like:
    -- tests/test_example.py:42: AssertionError
    -- src/calculator.py:8: ZeroDivisionError
    -- tests/test_math.py:15:
    local file, line_num = line:match([[([^:%s]+%.py):(%d+):]])

    if file and line_num then
        return { file, line_num }
    end

    -- Match FAILED lines like:
    -- FAILED tests/test_math.py::test_division - ZeroDivisionError
    file = line:match([[FAILED ([^:]+%.py)]])
    if file then
        -- Extract just the file path, removing test name
        file = file:match([[([^:]+%.py)]])
        return { file, nil }
    end

    return { nil, nil }
end

return pytest
