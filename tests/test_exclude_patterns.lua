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

T["exclude_patterns"] = MiniTest.new_set()

T["exclude_patterns"]["filters out node_modules files"] = function()
    child.lua([[require('nvim-unstack').setup({ layout = "quickfix_list" })]])

    child.lua([[
        local cwd = vim.loop.cwd()
        
        -- Create test matches with mixed paths
        local matches = {
            { cwd .. "/src/app.js", "10" },                      -- In project
            { cwd .. "/node_modules/express/lib/app.js", "20" }, -- Dependency
            { cwd .. "/tests/test.js", "30" },                   -- In project
        }
        
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
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
    -- Should only have 2 items (node_modules excluded)
    MiniTest.expect.equality(qf_count, 2)

    local qf_items = child.lua_get("_G.test_qf_items")
    Helpers.expect.match(qf_items[1].filename, "app.js")
    MiniTest.expect.equality(qf_items[1].lnum, 10)
    Helpers.expect.match(qf_items[2].filename, "test.js")
    MiniTest.expect.equality(qf_items[2].lnum, 30)
end

T["exclude_patterns"]["filters out Python virtual environment files"] = function()
    child.lua([[require('nvim-unstack').setup({ layout = "quickfix_list" })]])

    child.lua([[
        local cwd = vim.loop.cwd()
        
        local matches = {
            { cwd .. "/src/main.py", "10" },
            { cwd .. "/.venv/lib/python3.11/site-packages/django/core.py", "20" },
            { cwd .. "/tests/test_main.py", "30" },
        }
        
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
        local qf_list = vim.fn.getqflist()
        _G.test_qf_count = #qf_list
    ]])

    local qf_count = child.lua_get("_G.test_qf_count")
    -- Should only have 2 items (.venv excluded)
    MiniTest.expect.equality(qf_count, 2)
end

T["exclude_patterns"]["filters out system libraries"] = function()
    child.lua([[require('nvim-unstack').setup({ layout = "quickfix_list" })]])

    child.lua([[
        local cwd = vim.loop.cwd()
        
        local matches = {
            { cwd .. "/src/main.py", "10" },
            { "/usr/lib/python3.11/typing.py", "20" },
            { cwd .. "/app/views.py", "30" },
        }
        
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
        local qf_list = vim.fn.getqflist()
        _G.test_qf_count = #qf_list
    ]])

    local qf_count = child.lua_get("_G.test_qf_count")
    -- Should only have 2 items (/usr/ excluded)
    MiniTest.expect.equality(qf_count, 2)
end

T["exclude_patterns"]["filters out vendor directory files"] = function()
    child.lua([[require('nvim-unstack').setup({ layout = "quickfix_list" })]])

    child.lua([[
        local cwd = vim.loop.cwd()
        
        local matches = {
            { cwd .. "/main.go", "10" },
            { cwd .. "/vendor/github.com/pkg/errors/errors.go", "20" },
            { cwd .. "/handlers/api.go", "30" },
        }
        
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
        local qf_list = vim.fn.getqflist()
        _G.test_qf_count = #qf_list
    ]])

    local qf_count = child.lua_get("_G.test_qf_count")
    -- Should only have 2 items (vendor/ excluded)
    MiniTest.expect.equality(qf_count, 2)
end

T["exclude_patterns"]["allows all files when disabled"] = function()
    child.lua(
        [[require('nvim-unstack').setup({ exclude_patterns = false, layout = "quickfix_list" })]]
    )

    child.lua([[
        local cwd = vim.loop.cwd()
        
        local matches = {
            { cwd .. "/src/app.js", "10" },
            { cwd .. "/node_modules/express/lib/app.js", "20" },
            { "/usr/lib/python3.11/typing.py", "30" },
        }
        
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
        local qf_list = vim.fn.getqflist()
        _G.test_qf_count = #qf_list
    ]])

    local qf_count = child.lua_get("_G.test_qf_count")
    -- Should have all items when exclude_patterns is false
    MiniTest.expect.equality(qf_count, 3)
end

T["exclude_patterns"]["allows custom patterns"] = function()
    child.lua([[require('nvim-unstack').setup({ 
        exclude_patterns = { "test_" }, 
        layout = "quickfix_list" 
    })]])

    child.lua([[
        local cwd = vim.loop.cwd()
        
        local matches = {
            { cwd .. "/src/main.py", "10" },
            { cwd .. "/tests/test_main.py", "20" },
            { cwd .. "/app/views.py", "30" },
        }
        
        local open_matches = require('nvim-unstack.util.open-matches')
        open_matches(matches)
        
        local qf_list = vim.fn.getqflist()
        _G.test_qf_count = #qf_list
    ]])

    local qf_count = child.lua_get("_G.test_qf_count")
    -- Should only have 2 items (test_ excluded)
    MiniTest.expect.equality(qf_count, 2)
end

return T
