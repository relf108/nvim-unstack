local pytest = {}

-- Pytest traceback lines look like:
-- tests/test_example.py:42: AssertionError
-- tests/test_example.py:15:
-- src/calculator.py:8: ZeroDivisionError
-- FAILED tests/test_math.py::test_division - ZeroDivisionError
pytest.name = "Pytest"
pytest.regex = vim.regex([[\v(^\s*\S+\.py:\d+:|^FAILED \S+\.py)]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function pytest.extract_matches(text)
    local matches = {}

    -- Match pytest output lines like: tests/test_example.py:42: AssertionError
    for file, line_num in text:gmatch("(%S+%.py):(%d+):") do
        table.insert(matches, { file, line_num })
    end

    -- Match FAILED lines like: FAILED tests/test_math.py::test_division
    for file in text:gmatch("FAILED ([^:]+%.py)") do
        -- FAILED summary lines don't include a line number; we still want a
        -- clickable location in the file, so we default to line 1 as a
        -- deterministic, safe choice. This may not be the exact failure line,
        -- but it's preferable to having no jump target at all.
        table.insert(matches, { file, "1" })
    end

    return matches
end

return pytest
