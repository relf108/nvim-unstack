local Helpers = dofile("tests/helpers.lua")

-- See https://github.com/echasnovski/mini.nvim/blob/main/lua/mini/test.lua for more documentation

local child = Helpers.new_child_neovim()

local T = MiniTest.new_set({
    hooks = {
        -- This will be executed before every (even nested) case
        pre_case = function()
            -- Restart child process with custom 'init.lua' script
            child.restart({ "-u", "scripts/minimal_init.lua" })
        end,
        -- This will be executed one after all tests from this set are finished
        post_once = child.stop,
    },
})

-- Tests related to the `setup` method.
T["setup()"] = MiniTest.new_set()

T["setup()"]["sets exposed methods and default options value"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    -- global object that holds your plugin information
    Helpers.expect.global_type(child, "_G.NvimUnstack", "table")

    -- config
    Helpers.expect.global_type(child, "_G.NvimUnstack.config", "table")

    -- assert the value, and the type
    Helpers.expect.config(child, "debug", false)
    Helpers.expect.config_type(child, "debug", "boolean")
end

T["setup()"]["overrides default values"] = function()
    child.lua([[require('nvim-unstack').setup({
        -- write all the options with a value different than the default ones
        debug = true,
    })]])

    -- assert the value, and the type
    Helpers.expect.config(child, "debug", true)
    Helpers.expect.config_type(child, "debug", "boolean")
end

-- Tests related to keymap configuration
T["setup()"]["creates default keymap when mapkey is not set"] = function()
    child.lua([[require('nvim-unstack').setup()]])

    -- Check that the default keymap is set by looking for the description
    local has_default_keymap = child.lua_get([[
        (function()
            -- Check buffer-local keymaps first
            local ok, maps = pcall(vim.api.nvim_buf_get_keymap, 0, 'v')
            if ok then
                for _, map in ipairs(maps) do
                    if map.desc and map.desc:find('Unstack') then
                        return true
                    end
                end
            end
            -- Check global keymaps
            maps = vim.api.nvim_get_keymap('v')
            for _, map in ipairs(maps) do
                if map.desc and map.desc:find('Unstack') then
                    return true
                end
            end
            return false
        end)()
    ]])

    Helpers.expect.config(child, "mapkey", "<leader>s")
    Helpers.expect.equality(has_default_keymap, true)
end

T["setup()"]["does not create keymap when mapkey is false"] = function()
    child.lua([[require('nvim-unstack').setup({
        mapkey = false,
    })]])

    -- Check that no default keymap is set
    local has_unstack_keymap = child.lua_get([[
        (function()
            local maps = vim.api.nvim_get_keymap('v')
            for _, map in ipairs(maps) do
                if map.desc and map.desc:find('Unstack') then
                    return true
                end
            end
            return false
        end)()
    ]])

    Helpers.expect.equality(has_unstack_keymap, false)
end

T["setup()"]["accepts boolean for mapkey config"] = function()
    child.lua([[require('nvim-unstack').setup({
        mapkey = false,
    })]])

    Helpers.expect.config(child, "mapkey", false)
    Helpers.expect.config_type(child, "mapkey", "boolean")
end

T["setup()"]["accepts string for mapkey config"] = function()
    child.lua([[require('nvim-unstack').setup({
        mapkey = "<leader>ct",
    })]])

    Helpers.expect.config(child, "mapkey", "<leader>ct")
    Helpers.expect.config_type(child, "mapkey", "string")
end

return T
