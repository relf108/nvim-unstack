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

T["use_first_parser"] = MiniTest.new_set()

T["use_first_parser"]["returns first parser when enabled"] = function()
    child.lua([[require('nvim-unstack').setup({ use_first_parser = true })]])

    -- Python traceback that both python and pytest parsers would match
    local python_traceback = [[
Traceback (most recent call last):
  File "/app/main.py", line 10, in <module>
    raise ValueError("test error")
ValueError: test error
]]

    -- Should use first parser without showing popup via callback
    child.lua(string.format(
        [[
        local lines = vim.split(%s, "\n")
        
        local traceback_filetype = require('nvim-unstack.util.traceback-filetype')
        
        _G.test_parser_used = nil
        traceback_filetype(lines, function(parser)
            _G.test_parser_used = parser.name
        end)
    ]],
        vim.inspect(python_traceback)
    ))

    local parser_used = child.lua_get("_G.test_parser_used")
    -- Should be Python (first matching parser)
    MiniTest.expect.equality(parser_used, "Python")
end

T["use_first_parser"]["shows popup when disabled with multiple matches"] = function()
    child.lua([[require('nvim-unstack').setup({ use_first_parser = false })]])

    -- Python traceback that both python and pytest parsers would match
    local python_traceback = [[
Traceback (most recent call last):
  File "/app/main.py", line 10, in <module>
    raise ValueError("test error")
ValueError: test error
]]

    child.lua(string.format(
        [[
        local lines = vim.split(%s, "\n")
        
        -- Mock vim.ui.select to capture that it was called
        _G.test_select_called = false
        _G.test_select_items = nil
        _G.test_parser_result = nil
        
        local original_select = vim.ui.select
        vim.ui.select = function(items, opts, on_choice)
            _G.test_select_called = true
            _G.test_select_items = {}
            for i, item in ipairs(items) do
                table.insert(_G.test_select_items, item.name)
            end
            -- Simulate user selecting first option
            vim.schedule(function()
                on_choice(items[1], 1)
            end)
        end
        
        local traceback_filetype = require('nvim-unstack.util.traceback-filetype')
        traceback_filetype(lines, function(parser)
            _G.test_parser_result = parser.name
        end)
        
        vim.ui.select = original_select
    ]],
        vim.inspect(python_traceback)
    ))

    -- Wait for async callback
    vim.wait(100)

    local select_called = child.lua_get("_G.test_select_called")
    MiniTest.expect.equality(select_called, true)

    local select_items = child.lua_get("_G.test_select_items")
    -- Should have both Python and Pytest as options
    MiniTest.expect.equality(vim.tbl_contains(select_items, "Python"), true)
    MiniTest.expect.equality(vim.tbl_contains(select_items, "Pytest"), true)
end

T["use_first_parser"]["uses first parser when user cancels popup"] = function()
    child.lua([[require('nvim-unstack').setup({ use_first_parser = false })]])

    local python_traceback = [[
Traceback (most recent call last):
  File "/app/main.py", line 10, in <module>
    raise ValueError("test error")
ValueError: test error
]]

    child.lua(string.format(
        [[
        local lines = vim.split(%s, "\n")
        
        -- Mock vim.ui.select to simulate user cancelling
        local original_select = vim.ui.select
        vim.ui.select = function(items, opts, on_choice)
            -- Simulate user pressing Esc (nil selection)
            on_choice(nil, nil)
        end
        
        local traceback_filetype = require('nvim-unstack.util.traceback-filetype')
        traceback_filetype(lines, function(parser)
            _G.test_parser_result = parser.name
        end)
        
        vim.ui.select = original_select
    ]],
        vim.inspect(python_traceback)
    ))

    local parser_result = child.lua_get("_G.test_parser_result")
    -- Should fallback to first parser (Python)
    MiniTest.expect.equality(parser_result, "Python")
end

T["use_first_parser"]["single parser match does not trigger popup"] = function()
    child.lua([[require('nvim-unstack').setup({ use_first_parser = false })]])

    -- Go traceback that only go parser matches
    local go_traceback = [[
panic: runtime error: invalid memory address or nil pointer dereference
	/app/main.go:42 +0x1a
]]

    child.lua(string.format(
        [[
        local lines = vim.split(%s, "\n")
        
        -- Mock vim.ui.select to check it's not called
        _G.test_select_called = false
        
        local original_select = vim.ui.select
        vim.ui.select = function(items, opts, on_choice)
            _G.test_select_called = true
        end
        
        local traceback_filetype = require('nvim-unstack.util.traceback-filetype')
        traceback_filetype(lines, function(parser)
            _G.test_parser_result = parser.name
        end)
        
        vim.ui.select = original_select
    ]],
        vim.inspect(go_traceback)
    ))

    local select_called = child.lua_get("_G.test_select_called")
    -- Should NOT show popup for single match
    MiniTest.expect.equality(select_called, false)

    local parser_result = child.lua_get("_G.test_parser_result")
    MiniTest.expect.equality(parser_result, "Go")
end

T["Parser selection"] = MiniTest.new_set()

T["Parser selection"]["formats parser names in popup"] = function()
    child.lua([[require('nvim-unstack').setup({ use_first_parser = false })]])

    local python_traceback = [[
Traceback (most recent call last):
  File "/app/main.py", line 10, in <module>
    raise ValueError("test error")
ValueError: test error
]]

    child.lua(string.format(
        [[
        local lines = vim.split(%s, "\n")
        
        _G.test_prompt = nil
        _G.test_formatted_items = {}
        
        local original_select = vim.ui.select
        vim.ui.select = function(items, opts, on_choice)
            _G.test_prompt = opts.prompt
            
            if opts.format_item then
                for _, item in ipairs(items) do
                    table.insert(_G.test_formatted_items, opts.format_item(item))
                end
            end
            
            vim.schedule(function()
                on_choice(items[1], 1)
            end)
        end
        
        local traceback_filetype = require('nvim-unstack.util.traceback-filetype')
        traceback_filetype(lines, function(parser) end)
        
        vim.ui.select = original_select
    ]],
        vim.inspect(python_traceback)
    ))

    -- Wait for async callback
    vim.wait(100)

    local prompt = child.lua_get("_G.test_prompt")
    MiniTest.expect.equality(prompt, "Select a parser:")

    local formatted_items = child.lua_get("_G.test_formatted_items")
    -- Should show parser names
    MiniTest.expect.equality(vim.tbl_contains(formatted_items, "Python"), true)
end

return T
