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

-- Tests for configuration validation
T["Configuration"] = MiniTest.new_set()

T["Configuration"]["validates debug option type"] = function()
    child.lua([[
        local status, err = pcall(function()
            require('nvim-unstack').setup({ debug = "not a boolean" })
        end)
        _G.test_result = status
    ]])

    local status = child.lua_get("_G.test_result")
    MiniTest.expect.equality(status, false)
end

T["Configuration"]["validates showsigns option type"] = function()
    child.lua([[
        local status, err = pcall(function()
            require('nvim-unstack').setup({ showsigns = "not a boolean" })
        end)
        _G.test_result = status
    ]])

    local status = child.lua_get("_G.test_result")
    MiniTest.expect.equality(status, false)
end

T["Configuration"]["validates mapkey option type"] = function()
    child.lua([[
        local status, err = pcall(function()
            require('nvim-unstack').setup({ mapkey = 123 })
        end)
        _G.test_result = status
    ]])

    local status = child.lua_get("_G.test_result")
    MiniTest.expect.equality(status, false)
end

T["Configuration"]["accepts custom mapkey"] = function()
    child.lua([[require('nvim-unstack').setup({ mapkey = "<leader>u" })]])

    Helpers.expect.config(child, "mapkey", "<leader>u")
end

T["Configuration"]["defines signs when showsigns is true"] = function()
    child.lua([[require('nvim-unstack').setup({ showsigns = true })]])

    child.lua([[
        local signs = vim.fn.sign_getdefined("UnstackLine")
        _G.test_result = #signs > 0
    ]])

    local sign_defined = child.lua_get("_G.test_result")
    MiniTest.expect.equality(sign_defined, true)
end

-- Tests for different layouts
T["Layouts"] = MiniTest.new_set()

T["Layouts"]["validates layout option"] = function()
    child.lua([[
        local status, err = pcall(function()
            require('nvim-unstack').setup({ layout = "invalid" })
        end)
        _G.test_result = status
    ]])

    local status = child.lua_get("_G.test_result")
    MiniTest.expect.equality(status, false)
end

T["Layouts"]["accepts valid layouts"] = function()
    local layouts = { "tab", "vsplit", "split", "floating", "quickfix_list" }

    for _, layout in ipairs(layouts) do
        child.restart({ "-u", "scripts/minimal_init.lua" })

        child.lua(string.format(
            [[
            local status, err = pcall(function()
                require('nvim-unstack').setup({ layout = "%s" })
            end)
            _G.test_result = status
        ]],
            layout
        ))

        local status = child.lua_get("_G.test_result")
        MiniTest.expect.equality(status, true)
    end
end

T["Layouts"]["quickfix_list populates quickfix list correctly"] = function()
    child.lua([[require('nvim-unstack').setup({ layout = "quickfix_list" })]])

    child.lua([[
        -- Create test matches
        local matches = {
            { "test_file1.py", "10" },
            { "test_file2.py", "20" },
            { "test_file3.py", "30" },
        }
        
        -- Call open_matches directly with the matches
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
        -- Get the quickfix list
        local qf_list = vim.fn.getqflist()
        
        _G.test_qf_count = #qf_list
        _G.test_qf_items = {}
        for i, item in ipairs(qf_list) do
            _G.test_qf_items[i] = {
                filename = vim.fn.bufname(item.bufnr),
                lnum = item.lnum
            }
        end
    ]])

    local qf_count = child.lua_get("_G.test_qf_count")
    MiniTest.expect.equality(qf_count, 3)

    local qf_items = child.lua_get("_G.test_qf_items")
    MiniTest.expect.equality(qf_items[1].filename, "test_file1.py")
    MiniTest.expect.equality(qf_items[1].lnum, 10)
    MiniTest.expect.equality(qf_items[2].filename, "test_file2.py")
    MiniTest.expect.equality(qf_items[2].lnum, 20)
    MiniTest.expect.equality(qf_items[3].filename, "test_file3.py")
    MiniTest.expect.equality(qf_items[3].lnum, 30)
end

-- Tests for clipboard functionality
T["Clipboard"] = MiniTest.new_set()

T["Clipboard"]["handles empty clipboard"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        vim.fn.setreg("+", "")
        
        local notified = false
        local original_notify = vim.notify
        vim.notify = function(msg, level)
            if level == vim.log.levels.WARN then
                notified = true
            end
        end
        
        require('nvim-unstack').unstack_from_clipboard()
        vim.notify = original_notify
        
        _G.test_result = notified
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

-- Tests for error handling
T["Error handling"] = MiniTest.new_set()

T["Error handling"]["handles empty input gracefully"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local lines = {}
        local status, err = pcall(function()
            local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
            return tracebackFiletype(lines)
        end)
        _G.test_result = status
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, false)
end

T["Error handling"]["handles non-traceback input"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([=[
        local random_text = [[
This is just some random text
that doesn't look like a traceback
at all.
]]

        local lines = vim.split(random_text, "\n")
        local status, err = pcall(function()
            local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
            return tracebackFiletype(lines)
        end)
        _G.test_result = status
    ]=])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, false)
end

-- Tests for traceback filetype detection
T["Traceback detection"] = MiniTest.new_set()

T["Traceback detection"]["detects Python traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([=[
        local traceback = [[
Traceback (most recent call last):
  File "/path/to/file.py", line 42, in main
    do_something()
]]

        local lines = vim.split(traceback, "\n")
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        local parser = tracebackFiletype(lines)
        local python = require("nvim-unstack.regex.python")
        
        local result = false
        for _, line in ipairs(lines) do
            if python.regex:match_str(line) == 0 then
                result = true
                break
            end
        end
        
        _G.test_result = result
    ]=])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Traceback detection"]["detects Pytest traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local traceback = "tests/test_example.py:42: AssertionError"

        local lines = vim.split(traceback, "\n")
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        local parser = tracebackFiletype(lines)
        local pytest = require("nvim-unstack.regex.pytest")
        
        local result = false
        for _, line in ipairs(lines) do
            if pytest.regex:match_str(line) == 0 then
                result = true
                break
            end
        end
        
        _G.test_result = result
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Traceback detection"]["detects Node.js traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local traceback = "    at processData (/home/user/project/src/processor.js:15:10)"

        local lines = vim.split(traceback, "\n")
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        local parser = tracebackFiletype(lines)
        local nodejs = require("nvim-unstack.regex.nodejs")
        
        local result = false
        for _, line in ipairs(lines) do
            if nodejs.regex:match_str(line) == 0 then
                result = true
                break
            end
        end
        
        _G.test_result = result
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Traceback detection"]["detects Ruby traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local traceback = "	from /home/user/app/main.rb:42:in `main'"

        local lines = vim.split(traceback, "\n")
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        local parser = tracebackFiletype(lines)
        local ruby = require("nvim-unstack.regex.ruby")
        
        local result = false
        for _, line in ipairs(lines) do
            if ruby.regex:match_str(line) == 0 then
                result = true
                break
            end
        end
        
        _G.test_result = result
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

T["Traceback detection"]["detects Go traceback"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local traceback = "	/home/user/project/processor.go:15 +0x50"

        local lines = vim.split(traceback, "\n")
        local tracebackFiletype = require("nvim-unstack.util.traceback-filetype")
        local parser = tracebackFiletype(lines)
        local go = require("nvim-unstack.regex.go")
        
        local result = false
        for _, line in ipairs(lines) do
            if go.regex:match_str(line) == 0 then
                result = true
                break
            end
        end
        
        _G.test_result = result
    ]])

    local result = child.lua_get("_G.test_result")
    MiniTest.expect.equality(result, true)
end

-- Tests for parser edge cases
T["Parser edge cases"] = MiniTest.new_set()

T["Parser edge cases"]["Pytest parser handles colon-only lines"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local text = "tests/test_example.py:15:"
        local matches = pytest.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "tests/test_example.py")
    MiniTest.expect.equality(result[2], "15")
end

T["Parser edge cases"]["handles files with no line numbers gracefully"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    child.lua([[
        local pytest = require("nvim-unstack.regex.pytest")
        local text = "FAILED tests/test_math.py::test_division - ZeroDivisionError"
        local matches = pytest.extract_matches(text)
        _G.test_match = matches[1]
    ]])

    local result = child.lua_get("_G.test_match")
    MiniTest.expect.equality(result[1], "tests/test_math.py")
    -- Line number should be nil
    MiniTest.expect.equality(result[2], nil)
end

return T
