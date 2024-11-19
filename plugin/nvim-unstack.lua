-- Define exposed user commands.

-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.NvimUnstackLoaded then
    return
end

_G.NvimUnstackLoaded = true

-- Useful if you want your plugin to be compatible with older (<0.7) neovim versions
if vim.fn.has("nvim-0.7") == 0 then
    vim.cmd("command! NvimUnstack lua require('nvim-unstack').unstack()")
    vim.cmd("command! NvimUnstackEnable lua require('nvim-unstack').enable()")
    vim.cmd("command! NvimUnstackDisable lua require('nvim-unstack').disable()")
    vim.cmd("command! NvimUnstackToggle lua require('nvim-unstack').toggle()")
else
    vim.api.nvim_create_user_command("NvimUnstack", function()
        require("nvim-unstack").unstack()
    end, {})
    vim.api.nvim_create_user_command("NvimUnstackEnable", function()
        require("nvim-unstack").enable()
    end, {})
    vim.api.nvim_create_user_command("NvimUnstackDisable", function()
        require("nvim-unstack").disable()
    end, {})
    vim.api.nvim_create_user_command("NvimUnstackToggle", function()
        require("nvim-unstack").toggle()
    end, {})

    -- Default keymaps, need to decide if these should be here or even exist.
    vim.keymap.set("v", "<leader>x", function()
        require("nvim-unstack").unstack()
    end, {})
end
