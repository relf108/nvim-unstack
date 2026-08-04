local unwrap = require("nvim-unstack.util.unwrap")

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

    return nil, nil
end

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function pytest.extract_matches(text)
    return unwrap.extract_matches(text, match_line)
end

return pytest
