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
        -- When filename has a literal newline in the quoted string, parser should match
        local text = '  File "/home/user/very/long/path/that/continues/\nto/another/line/file.py", line 456, in function_name'
        local matches = python.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(
        result[1],
        "/home/user/very/long/path/that/continues/\nto/another/line/file.py"
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

T["Pytest parser"]["handles FAILED lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local text = "FAILED tests/test_math.py::test_division - ZeroDivisionError"
        local matches = pytest.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "tests/test_math.py")
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
