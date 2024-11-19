-- You can use this loaded variable to enable conditional parts of your plugin.
if _G.NvimUnstackLoaded then
    return
end

_G.NvimUnstackLoaded = true

-- Useful if you want your plugin to be compatible with older (<0.7) neovim versions
if vim.fn.has("nvim-0.7") == 0 then
    vim.cmd("command! NvimUnstack lua require('nvim-unstack').toggle()")
else
    vim.api.nvim_create_user_command("NvimUnstack", function()
        require("nvim-unstack").toggle()
    end, {})
end
