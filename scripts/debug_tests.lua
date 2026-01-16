-- Debug test runner
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    package.path = package.path
        .. ";"
        .. os.getenv("HOME")
        .. "/local-lua-debugger-vscode/debugger/?.lua"
    require("lldebugger").start()
end

print("Starting tests...\n")

-- Run the tests
local results =
    MiniTest.run({ execute = { reporter = MiniTest.gen_reporter.stdout({ group_depth = 2 }) } })

print("\nTests completed\n")
print(vim.inspect(results) .. "\n")

-- Exit nvim
vim.cmd("qa!")
