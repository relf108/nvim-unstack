local Helpers = dofile("tests/helpers.lua")

local child = Helpers.new_child_neovim()

local T = MiniTest.new_set({
    hooks = {
        pre_case = function()
            child.restart({ "-u", "scripts/minimal_init.lua" })
        end,
        post_once = child.stop,
    },
})

-- Tests for Python parser
T["Python parser"] = MiniTest.new_set()

T["Python parser"]["parses standard Python traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([=[
        local traceback = "\n\
Traceback (most recent call last):\n\
  File \"/path/to/myproject/main.py\", line 42, in main\n\
    result = process_data(data)\n\
  File \"/path/to/myproject/utils.py\", line 15, in process_data\n\
    return transform(data)\n\
"

        local lines = vim.split(traceback, "\n")
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
            _G.test_result = parser ~= nil and type(parser.regex) == "userdata"
        end)
    ]=])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Python parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        local text = '  File "/path/to/myproject/main.py", line 42, in main'
        local matches = python.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "/path/to/myproject/main.py")
    MiniTest.expect.equality(result[2], "42")
end

T["Python parser"]["handles line-wrapped tracebacks"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        local text = '  File "/some/very/long/path/to/project/directory/with/nested/folders/module.py", line 123, in some_very_long_function_name\n    some_code_that_caused_error()'
        local matches = python.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(
        result[1],
        "/some/very/long/path/to/project/directory/with/nested/folders/module.py"
    )
    MiniTest.expect.equality(result[2], "123")
end

T["Python parser"]["handles filename wrapping over two lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        -- When filename wraps to next line without leading whitespace
        -- (terminal hard wrap: the first segment is exactly terminal-width
        -- chars, so it is always the longest line in the selection)
        local text = '  File "/home/user/very/long/path/that/continues/to/another/\nline/file.py", line 456, in function_name'
        local matches = python.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    -- After unwrapping, the filename should be continuous
    MiniTest.expect.equality(
        result[1],
        "/home/user/very/long/path/that/continues/to/another/line/file.py"
    )
    MiniTest.expect.equality(result[2], "456")
end

T["Python parser"]["handles filename and line number over two lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        -- When line number has whitespace/newline before it, parser should now match
        local text = '  File "/home/user/project/src/components/utils/helpers.py", line \n789, in helper_function'
        local matches = python.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    -- The pattern now uses %s* to match whitespace including newlines
    MiniTest.expect.equality(result[1], "/home/user/project/src/components/utils/helpers.py")
    MiniTest.expect.equality(result[2], "789")
end

T["Python parser"]["handles word 'line' split across lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        -- When the word "line" itself is split across lines (e.g., "l\nine")
        local text = '  File "/Users/tristan.sutton/Origin/appdev-b2b-api/src/endpoints/energy.py", l\nine 337, in get_site_benefit'
        local matches = python.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(
        result[1],
        "/Users/tristan.sutton/Origin/appdev-b2b-api/src/endpoints/energy.py"
    )
    MiniTest.expect.equality(result[2], "337")
end

T["Python parser"]["rejoins paths hard-wrapped by the terminal"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        local width = 80
        local full = "/Users/tristan.sutton/Origin/appdev-api-charts/src/endpoints/deeply/nested/energy.py"
        local frame = '  File "' .. full .. '", line 337, in handler'
        local lines = {
            "Traceback (most recent call last):",
            frame:sub(1, width),
            frame:sub(width + 1),
            "    raise ValueError(\"test error\")",
            "ValueError: test error",
        }
        _G.test_full = full
        _G.test_matches = python.extract_matches(table.concat(lines, "\n"))
    ]])

    local matches = child.lua_get("_G.test_matches")
    local full = child.lua_get("_G.test_full")
    MiniTest.expect.equality(#matches, 1)
    MiniTest.expect.equality(matches[1][1], full)
    MiniTest.expect.equality(matches[1][2], "337")
end

-- Tests for Pytest parser
T["Pytest parser"] = MiniTest.new_set()

T["Pytest parser"]["parses pytest failure output"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {
            "=================================== FAILURES ===================================",
            "____________________________ test_my_function __________________________________",
            "",
            "    def test_my_function():",
            ">       assert result == expected",
            "E       AssertionError: assert 15 == 10",
            "",
            "tests/test_example.py:42: AssertionError"
        }
        
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
        _G.test_result = parser ~= nil
        end)
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Pytest parser"]["extracts file and line from pytest output"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local text = "tests/test_example.py:42: AssertionError"
        local matches = pytest.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "tests/test_example.py")
    MiniTest.expect.equality(result[2], "42")
end

T["Pytest parser"]["ignores FAILED lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local text = "FAILED tests/test_math.py::test_division - ZeroDivisionError"
        local matches = pytest.extract_matches(text)
        _G.test_count = #matches
    ]])

    -- FAILED summary lines carry no line number, so no match is extracted
    local result = child.lua_get("_G.test_count")
    MiniTest.expect.equality(result, 0)
end

T["Pytest parser"]["ignores ERROR summary lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local text = "ERROR tests/unit/test_utils.py"
        local matches = pytest.extract_matches(text)
        _G.test_count = #matches
    ]])

    -- ERROR summary lines carry no line number, so no match is extracted
    local result = child.lua_get("_G.test_count")
    MiniTest.expect.equality(result, 0)
end

T["Pytest parser"]["parses collection error without caret-line corruption"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local full = "../../.local/share/uv/python/cpython-3.13.13/lib/python3.13/importlib/__init__.py"
        local lines = {
            "__________ ERROR collecting tests/unit/test_utils.py __________",
            "Traceback:",
            full .. ":88: in import_module",
            "    return _bootstrap._gcd_import(name[level:], package, level)",
            "           " .. string.rep("^", 44),
            "tests/unit/test_utils.py:1: in <module>",
            "    from src.utils import fix_openapi_spec_anyof",
            "E   ImportError: cannot import name 'fix_openapi_spec_anyof' from 'src.utils'",
            "ERROR tests/unit/test_utils.py",
        }
        _G.test_full = full
        _G.test_matches = pytest.extract_matches(table.concat(lines, "\n"))
    ]])

    local matches = child.lua_get("_G.test_matches")
    local full = child.lua_get("_G.test_full")
    MiniTest.expect.equality(#matches, 2)
    MiniTest.expect.equality(matches[1][1], full)
    MiniTest.expect.equality(matches[1][2], "88")
    MiniTest.expect.equality(matches[2][1], "tests/unit/test_utils.py")
    MiniTest.expect.equality(matches[2][2], "1")
end

T["Pytest parser"]["rejoins paths hard-wrapped by the terminal"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local width = 80
        local full = "../../.local/share/uv/python/cpython-3.13.13-macos-aarch64-none/lib/python3.13/importlib/__init__.py"
        local loc = full .. ":88: in import_module"
        local lines = {
            string.rep("=", 36) .. " ERRORS " .. string.rep("=", 36),
            "Traceback:",
            loc:sub(1, width),
            loc:sub(width + 1),
            "    return _bootstrap._gcd_import(name[level:], package, level)",
            "           " .. string.rep("^", 44),
            "tests/unit/test_utils.py:1: in <module>",
            "    from src.utils import fix_openapi_spec_anyof",
            "E   ImportError: cannot import name 'fix_openapi_spec_anyof' from 'src.utils'",
            string.rep("=", width),
            "ERROR tests/unit/test_utils.py",
        }
        _G.test_full = full
        _G.test_matches = pytest.extract_matches(table.concat(lines, "\n"))
    ]])

    local matches = child.lua_get("_G.test_matches")
    local full = child.lua_get("_G.test_full")
    MiniTest.expect.equality(#matches, 2)
    MiniTest.expect.equality(matches[1][1], full)
    MiniTest.expect.equality(matches[1][2], "88")
    MiniTest.expect.equality(matches[2][1], "tests/unit/test_utils.py")
    MiniTest.expect.equality(matches[2][2], "1")
end

-- Tests for Node.js parser
T["Node.js parser"] = MiniTest.new_set()

T["Node.js parser"]["parses Node.js stack trace"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {
            "Error: Something went wrong",
            "    at processData (/home/user/project/src/processor.js:15:10)",
            "    at main (/home/user/project/index.js:42:5)"
        }

        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
        _G.test_result = parser ~= nil
        end)
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Node.js parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local nodejs = require("nvim-unstack.regex.nodejs")
        local text = "    at processData (/home/user/project/src/processor.js:15:10)"
        local matches = nodejs.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "/home/user/project/src/processor.js")
    MiniTest.expect.equality(result[2], "15")
end

T["Node.js parser"]["rejoins paths hard-wrapped by the terminal"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local nodejs = require("nvim-unstack.regex.nodejs")
        local width = 80
        local full = "/home/user/project/very/long/nested/path/to/some/module/src/processor.js"
        local frame = "    at processData (" .. full .. ":15:10)"
        local lines = {
            "Error: Something went wrong",
            frame:sub(1, width),
            frame:sub(width + 1),
            "    at main (/home/user/project/index.js:42:5)",
        }
        _G.test_full = full
        _G.test_matches = nodejs.extract_matches(table.concat(lines, "\n"))
    ]])

    local matches = child.lua_get("_G.test_matches")
    local full = child.lua_get("_G.test_full")
    MiniTest.expect.equality(#matches, 2)
    MiniTest.expect.equality(matches[1][1], full)
    MiniTest.expect.equality(matches[1][2], "15")
    MiniTest.expect.equality(matches[2][1], "/home/user/project/index.js")
    MiniTest.expect.equality(matches[2][2], "42")
end

-- Tests for Ruby parser
T["Ruby parser"] = MiniTest.new_set()

T["Ruby parser"]["parses Ruby backtrace"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {
            "Traceback (most recent call last):",
            "\tfrom /home/user/app/main.rb:42:in `main'",
            "\tfrom /home/user/app/processor.rb:15:in `process'"
        }

        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
        _G.test_result = parser ~= nil
        end)
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Ruby parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local ruby = require("nvim-unstack.regex.ruby")
        local text = "\tfrom /home/user/app/main.rb:42:in `main'"
        local matches = ruby.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "/home/user/app/main.rb")
    MiniTest.expect.equality(result[2], "42")
end

T["Ruby parser"]["rejoins paths hard-wrapped by the terminal"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local ruby = require("nvim-unstack.regex.ruby")
        local width = 80
        local full = "/home/user/app/services/very/long/nested/path/to/deeply/buried/processor.rb"
        local frame = "\tfrom " .. full .. ":15:in `process'"
        local lines = {
            "\tfrom /home/user/app/main.rb:42:in `main'",
            frame:sub(1, width),
            frame:sub(width + 1),
        }
        _G.test_full = full
        _G.test_matches = ruby.extract_matches(table.concat(lines, "\n"))
    ]])

    local matches = child.lua_get("_G.test_matches")
    local full = child.lua_get("_G.test_full")
    MiniTest.expect.equality(#matches, 2)
    MiniTest.expect.equality(matches[1][1], "/home/user/app/main.rb")
    MiniTest.expect.equality(matches[1][2], "42")
    MiniTest.expect.equality(matches[2][1], full)
    MiniTest.expect.equality(matches[2][2], "15")
end

-- Tests for Go parser
T["Go parser"] = MiniTest.new_set()

T["Go parser"]["parses Go panic stack trace"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {
            "panic: runtime error: index out of range",
            "",
            "goroutine 1 [running]:",
            "main.processData(0x0, 0x0)",
            "\t/home/user/project/processor.go:15 +0x50",
            "main.main()",
            "\t/home/user/project/main.go:42 +0x30"
        }

        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
        _G.test_result = parser ~= nil
        end)
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Go parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local go = require("nvim-unstack.regex.go")
        local text = "\t/home/user/project/processor.go:15 +0x50"
        local matches = go.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    -- The Go parser strips leading whitespace
    MiniTest.expect.equality(result[1], "/home/user/project/processor.go")
    MiniTest.expect.equality(result[2], "15")
end

T["Go parser"]["rejoins paths hard-wrapped by the terminal"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local go = require("nvim-unstack.regex.go")
        local width = 80
        local full = "/home/user/go/src/github.com/org/repo/internal/service/deeply/nested/handler.go"
        local frame = "\t" .. full .. ":42 +0x1a"
        local lines = {
            "goroutine 1 [running]:",
            "main.main()",
            frame:sub(1, width),
            frame:sub(width + 1),
        }
        _G.test_full = full
        _G.test_matches = go.extract_matches(table.concat(lines, "\n"))
    ]])

    local matches = child.lua_get("_G.test_matches")
    local full = child.lua_get("_G.test_full")
    -- The wrap-continuation segment also looks like a location line on its
    -- own; the parser must suppress it rather than emit a partial path.
    MiniTest.expect.equality(#matches, 1)
    MiniTest.expect.equality(matches[1][1], full)
    MiniTest.expect.equality(matches[1][2], "42")
end

-- Tests for multiple matches in single traceback
T["Multiple matches"] = MiniTest.new_set()

T["Multiple matches"]["extracts all Python matches from traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {
            "Traceback (most recent call last):",
            '  File "/path/to/first.py", line 10, in func1',
            "    call_something()",
            '  File "/path/to/second.py", line 20, in func2',
            "    call_another()",
            '  File "/path/to/third.py", line 30, in func3',
            "    raise Exception()"
        }

        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
        local text = table.concat(lines, "\n")
        local matches = parser.extract_matches(text)
        
        _G.test_count = #matches
        end)
    ]])

    local count = child.lua_get("_G.test_count")
    MiniTest.expect.equality(count, 3)
end

T["Multiple matches"]["extracts all Node.js matches from traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {
            "Error: Something went wrong",
            "    at func1 (/home/user/first.js:10:5)",
            "    at func2 (/home/user/second.js:20:10)",
            "    at func3 (/home/user/third.js:30:15)"
        }

        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        tracebackFiletype(lines, function(parser)
        local text = table.concat(lines, "\n")
        local matches = parser.extract_matches(text)
        
        _G.test_count = #matches
        end)
    ]])

    local count = child.lua_get("_G.test_count")
    MiniTest.expect.equality(count, 3)
end

return T
