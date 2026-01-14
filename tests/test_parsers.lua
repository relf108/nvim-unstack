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
        local parser = tracebackFiletype(lines)
        _G.test_result = parser ~= nil and type(parser.regex) == "userdata"
    ]=])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Python parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local python = require("nvim-unstack.regex.python")
        local line = '  File "/path/to/myproject/main.py", line 42, in main'
        local match = python.format_match(line)
        _G.test_match = match
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "/path/to/myproject/main.py")
    MiniTest.expect.equality(result[2], "42")
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
        local parser = tracebackFiletype(lines)
        _G.test_result = parser ~= nil
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Pytest parser"]["extracts file and line from pytest output"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local line = "tests/test_example.py:42: AssertionError"
        local match = pytest.format_match(line)
        _G.test_match = match
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "tests/test_example.py")
    MiniTest.expect.equality(result[2], "42")
end

T["Pytest parser"]["handles FAILED lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local line = "FAILED tests/test_math.py::test_division - ZeroDivisionError"
        local match = pytest.format_match(line)
        _G.test_match = match
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
        local parser = tracebackFiletype(lines)
        _G.test_result = parser ~= nil
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Node.js parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local nodejs = require("nvim-unstack.regex.nodejs")
        local line = "    at processData (/home/user/project/src/processor.js:15:10)"
        local match = nodejs.format_match(line)
        _G.test_match = match
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
        local parser = tracebackFiletype(lines)
        _G.test_result = parser ~= nil
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Ruby parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local ruby = require("nvim-unstack.regex.ruby")
        local line = "\tfrom /home/user/app/main.rb:42:in `main'"
        local match = ruby.format_match(line)
        _G.test_match = match
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
        local parser = tracebackFiletype(lines)
        _G.test_result = parser ~= nil
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Go parser"]["extracts file and line number"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local go = require("nvim-unstack.regex.go")
        local line = "\t/home/user/project/processor.go:15 +0x50"
        local match = go.format_match(line)
        _G.test_match = match
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
        local parser = tracebackFiletype(lines)
        local matches = {}
        
        for i, line in ipairs(lines) do
            if parser.regex:match_str(line) == 0 then
                table.insert(matches, parser.format_match(line, lines, i))
            end
        end
        
        _G.test_count = #matches
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
        local parser = tracebackFiletype(lines)
        local matches = {}
        
        for i, line in ipairs(lines) do
            if parser.regex:match_str(line) == 0 then
                table.insert(matches, parser.format_match(line, lines, i))
            end
        end
        
        _G.test_count = #matches
    ]])

    local count = child.lua_get("_G.test_count")
    MiniTest.expect.equality(count, 3)
end

return T
