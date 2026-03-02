local python = {}

python.name = "Python"
python.regex = vim.regex([[\v^ *File "([^"]+)"]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function python.extract_matches(text)
    local matches = {}
    -- Unwrap line-wrapped content by joining lines that don't start with whitespace
    -- Real traceback lines always start with spaces, wrapped lines continue without indent
    local unwrapped = text:gsub("\n([^%s])", "%1")

    -- Match Python traceback format
    for file, line_num in unwrapped:gmatch('File "([^"]+)",%s*line%s*(%d+)') do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return python
