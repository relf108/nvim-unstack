---@param matches table: the file path to jump to.
return function(matches)
    -- TODO @suttont: read in plugin conf to decide how to open matches.
    -- TODO @suttont: Drop and goto line in one operation so ctrl-o/i works.
    for _, match in ipairs(matches) do
        vim.cmd(":drop " .. match[1] .. "|" .. match[2])
    end
end
