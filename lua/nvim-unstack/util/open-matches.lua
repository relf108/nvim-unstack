---@param matches table: the file path to jump to.
return function(matches)
    local config = _G.NvimUnstack.config or require("nvim-unstack.config").options

    -- Ensure signs are defined if showsigns is enabled
    if config.showsigns then
        vim.fn.sign_define("UnstackLine", {
            text = ">>",
            texthl = "Search",
            linehl = "CursorLine",
        })
    end

    if #matches == 0 then
        return
    end

    -- Handle different layout configurations
    if config.layout == "floating" then
        -- Open all files in floating windows
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                -- Create a floating window
                local width = math.floor(vim.o.columns * 0.8)
                local height = math.floor(vim.o.lines * 0.8)
                local row = math.floor((vim.o.lines - height) / 2)
                local col = math.floor((vim.o.columns - width) / 2)

                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_open_win(buf, true, {
                    relative = "editor",
                    width = width,
                    height = height,
                    row = row,
                    col = col,
                    border = "single",
                    style = "minimal",
                })
                vim.cmd("edit " .. file)
                vim.cmd(":" .. line_num)

                -- Set up signs if configured
                if config.showsigns then
                    vim.fn.sign_place(0, "UnstackSigns", "UnstackLine", buf, {
                        lnum = tonumber(line_num),
                    })
                end
            end
        end
    elseif config.layout == "tab" then
        -- Open all files as splits in a new tab
        -- Capture current settings before creating new tab (using vim.opt to get actual values)
        local original_number = vim.opt.number:get()
        local original_relativenumber = vim.opt.relativenumber:get()

        vim.cmd("tabnew")

        for i, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                if i == 1 then
                    -- First file in the new tab
                    vim.cmd("edit " .. file)
                else
                    -- Vertical split for subsequent files, split to the right
                    vim.cmd("rightbelow vsplit " .. file)
                end
                vim.cmd(":" .. line_num)

                -- Apply number settings if they were originally enabled
                if original_number then
                    vim.opt.number = true
                end
                if original_relativenumber then
                    vim.opt.relativenumber = true
                end

                -- Set up signs if configured
                if config.showsigns then
                    vim.fn.sign_place(
                        0,
                        "UnstackSigns",
                        "UnstackLine",
                        vim.api.nvim_get_current_buf(),
                        {
                            lnum = tonumber(line_num),
                        }
                    )
                end
            end
        end
    else
        -- Handle vsplit, split, or fallback layouts
        local open_cmd
        if config.layout == "vsplit" then
            open_cmd = "vsplit"
        elseif config.layout == "split" then
            open_cmd = "split"
        else
            open_cmd = "drop" -- fallback
        end

        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                vim.cmd(open_cmd .. " " .. file)
                vim.cmd(":" .. line_num)

                -- Set up signs if configured
                if config.showsigns then
                    vim.fn.sign_place(
                        0,
                        "UnstackSigns",
                        "UnstackLine",
                        vim.api.nvim_get_current_buf(),
                        {
                            lnum = tonumber(line_num),
                        }
                    )
                end
            end
        end
    end
end
