-- Open matched files from stack trace.

local function place_sign(config, buf, line_num)
    if config.showsigns then
        vim.fn.sign_place(0, "UnstackSigns", "UnstackLine", buf, {
            lnum = line_num,
        })
    end
end

local layout_handlers = {
    floating = function(matches, config)
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
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

                place_sign(config, buf, line_num)
            end
        end
    end,

    tab = function(matches, config)
        local original_number = vim.opt.number:get()
        local original_relativenumber = vim.opt.relativenumber:get()

        vim.cmd("tabnew")

        for i, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                if i == 1 then
                    vim.cmd("edit " .. file)
                else
                    vim.cmd("rightbelow vsplit " .. file)
                end
                vim.cmd(":" .. line_num)

                if original_number then
                    vim.opt.number = true
                end
                if original_relativenumber then
                    vim.opt.relativenumber = true
                end

                place_sign(config, vim.api.nvim_get_current_buf(), line_num)
            end
        end
    end,

    vsplit = function(matches, config)
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                vim.cmd("vsplit " .. file)
                vim.cmd(":" .. line_num)
                place_sign(config, vim.api.nvim_get_current_buf(), line_num)
            end
        end
    end,

    split = function(matches, config)
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                vim.cmd("split " .. file)
                vim.cmd(":" .. line_num)
                place_sign(config, vim.api.nvim_get_current_buf(), line_num)
            end
        end
    end,

    quickfix_list = function(matches, _)
        local qf_items = {}
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                table.insert(qf_items, {
                    filename = file,
                    lnum = line_num,
                })
            end
        end
        vim.fn.setqflist(qf_items)
        vim.cmd("copen")
    end,
}

---@param matches table: the file path to jump to.
---@private
return function(matches)
    local config = _G.NvimUnstack.config or require("nvim-unstack.config").options

    if #matches == 0 then
        return
    end

    if config.exclude_patterns and type(config.exclude_patterns) == "table" then
        local validated_matches = {}
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            -- Resolve to absolute path
            local abs_file = vim.fn.fnamemodify(file, ":p")

            -- Check if file matches any exclude pattern
            local should_exclude = false
            for _, pattern in ipairs(config.exclude_patterns) do
                if abs_file:find(pattern) then
                    should_exclude = true
                    break
                end
            end

            if not should_exclude then
                table.insert(validated_matches, { file, line_num })
            end
        end
        matches = validated_matches
    end

    local handler = layout_handlers[config.layout]
    if handler then
        handler(matches, config)
    else
        -- Fallback for unknown layouts
        for _, match in ipairs(matches) do
            local file, line_num = match[1], match[2]
            if file and line_num then
                vim.cmd("drop " .. file)
                vim.cmd(":" .. line_num)
                place_sign(config, vim.api.nvim_get_current_buf(), line_num)
            end
        end
    end
end
