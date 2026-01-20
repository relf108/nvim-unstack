local python = {}

python.name = "Python"
python.regex = vim.regex([[\v^ *File "([^"]+)"]])

---@param text string: entire traceback as single string
---@return table: array of matches
---@private
function python.extract_matches(text)
    local matches = {}
    -- Match Python traceback format across lines
    -- Allow whitespace (including newlines) between components to handle line wrapping
    for file, line_num in text:gmatch('File "([^"]+)",%s*line%s*(%d+)') do
        table.insert(matches, { file, line_num })
    end
    return matches
end

return python
