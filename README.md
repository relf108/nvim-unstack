<!--toc:start-->

- [⚡️ Features](#️-features)
- [🎯 Supported Languages](#-supported-languages)
- [📋 Installation](#-installation)
- [☄ Getting started](#-getting-started)
- [⚙ Configuration](#-configuration)
- [🧰 Commands](#-commands)
- [🔧 API](#-api)
- [🎨 Customization](#-customization)
- [⌨ Contributing](#-contributing)
- [🗞 Wiki](#-wiki)
- [🎭 Motivations](#-motivations)
<!--toc:end-->

<p align="center">
  <h1 align="center">nvim-unstack</h1>
</p>

<p align="center">
    A powerful Neovim plugin for parsing and navigating stack traces from multiple programming languages.
</p>

<p align="center">
    Quickly jump to files and line numbers from stack traces with configurable layouts and visual indicators.
</p>

## ⚡️ Features

- **Multi-language support**: Built-in regex parsers for Python, Node.js, Ruby, Go, C#, Perl, and GDB/LLDB
- **Smart parser selection**: Automatically detects the right parser, or lets you choose when multiple match
- **Flexible layouts**: Open files in tabs, vertical splits, horizontal splits, floating windows, or quickfix list
- **Visual indicators**: Optional signs to highlight stack trace lines
- **Multiple input methods**: Parse from visual selection, clipboard, or tmux paste buffer
- **Configurable keymaps**: Customize the key binding for stack trace parsing
- **Easy extension**: Simple API for adding custom language parsers
- **Zero dependencies**: Pure Lua implementation with no external requirements

## 🎯 Supported Languages

nvim-unstack comes with built-in support for parsing stack traces from:

- **Python** - Standard Python tracebacks with file paths and line numbers
- **Pytest** - Pytest test failure tracebacks and assertion errors
- **Node.js** - JavaScript stack traces with file locations
- **Ruby** - Ruby exception backtraces
- **Go** - Go panic stack traces and error messages
- **C#** - .NET exception stack traces
- **Perl** - Perl error messages with file references
- **GDB/LLDB** - Debugger stack traces and breakpoint information

New language parsers can be easily added - see the [Customization](#-customization) section.

## 📋 Installation

<div align="center">
<table>
<thead>
<tr>
<th>Package manager</th>
<th>Snippet</th>
</tr>
</thead>
<tbody>
<tr>
<td>

[wbthomason/packer.nvim](https://github.com/wbthomason/packer.nvim)

</td>
<td>
<div align="left">

```lua
-- Stable version
use {"relf108/nvim-unstack", tag = "*" }
-- Development version
use {"relf108/nvim-unstack"}
```

</div>
</td>
</tr>
<tr>
<td>

[junegunn/vim-plug](https://github.com/junegunn/vim-plug)

</td>
<td>
<div align="left">

```vim
" Stable version
Plug 'relf108/nvim-unstack', { 'tag': '*' }
" Development version
Plug 'relf108/nvim-unstack'
```

</div>
</td>
</tr>
<tr>
<td>

[folke/lazy.nvim](https://github.com/folke/lazy.nvim)

</td>
<td>
<div align="left">

```lua
-- Stable version
{ "relf108/nvim-unstack", version = "*" }
-- Development version
{ "relf108/nvim-unstack" }
-- With configuration
{
	"relf108/nvim-unstack",
	event = "VeryLazy", -- Enable lazy loading
	version = "*",
	opts = {
		debug = false, -- Disable debug logging (default)
		showsigns = true, -- Enable signs (default)
		layout = "tab", -- Use tab layout (default)
		mapkey = "<leader>s", -- set keybinding (default)
		use_first_parser = true, -- Use first matching parser (default)
		exclude_patterns = { -- Filter out dependencies (default includes common paths)
              "node_modules", -- JavaScript/TypeScript dependencies
              ".venv", -- Python virtual environment
              "venv", -- Python virtual environment (alternate name)
              "site%-packages", -- Python installed packages
              "dist%-packages", -- Python system packages
              "/usr/", -- System libraries (Unix)
              "/lib/", -- System libraries
              "%.cargo/", -- Rust dependencies
              "vendor/", -- Ruby/Go dependencies
		},
	},
}
-- Lazy load on invocation
{
	"relf108/nvim-unstack",
	version = "*",
	lazy = true,
	cmd = "NvimUnstack",
	keys = { { "<leader>ct", "<cmd>NvimUnstack<cr>", mode = { "v" } } },
	opts = {
		mapkey = false, -- Skip mapping during setup so it doesn't conflict with `keys` config
	},
}
```

</div>
</td>
</tr>
</tbody>
</table>
</div>

## ☄ Getting started

### Basic Setup

After installation, you can start using nvim-unstack immediately with the default configuration:

```lua
require("nvim-unstack").setup()
```

### Quick Usage

1. **Visual Selection**: Select a stack trace (or part of one) and press `<leader>s` to open the referenced files
2. **From Clipboard**: Use `:UnstackFromClipboard` to parse a stack trace from your system clipboard
3. **From Tmux**: Use `:UnstackFromTmux` to parse a stack trace from tmux paste buffer

### Example

Given this Python traceback:

```
Traceback (most recent call last):
  File "/path/to/myproject/main.py", line 42, in main
    result = process_data(data)
  File "/path/to/myproject/utils.py", line 15, in process_data
    return transform(data)
```

Or this Pytest failure:

```
=================================== FAILURES ===================================
____________________________ test_my_function __________________________________

    def test_my_function():
>       assert result == expected
E       AssertionError: assert 15 == 10

tests/test_example.py:42: AssertionError
```

Simply select the traceback text and press `<leader>s`. The plugin will:

- Parse the file paths and line numbers
- Open each file at the specified line
- Display them according to your configured layout (tabs by default)

## ⚙ Configuration

nvim-unstack can be customized with the following options:

```lua
require("nvim-unstack").setup({
  -- Print debug information (default: false)
  debug = false,

  -- Layout for opening files (default: "tab")
  -- Options: "tab", "vsplit", "split", "floating", "quickfix_list"
  layout = "tab",

  -- Key mapping for visual selection unstacking (default: "<leader>s")
  mapkey = "<leader>s",

  -- Show signs on lines from stack trace (default: true)
  showsigns = true,

  -- Use first matching parser (default: true)
  -- When false, shows a selection prompt if multiple parsers match
  use_first_parser = true,

  -- Exclude file paths matching these patterns from stack traces
  -- Set to false to disable filtering, or provide a table of patterns
  -- Patterns are matched against the absolute file path
  exclude_patterns = {
    "node_modules",     -- JavaScript/TypeScript dependencies
    ".venv",            -- Python virtual environment
    "venv",             -- Python virtual environment (alternate name)
    "site%-packages",   -- Python installed packages
    "dist%-packages",   -- Python system packages
    "/usr/",            -- System libraries (Unix)
    "/lib/",            -- System libraries
    "%.cargo/",         -- Rust dependencies
    "vendor/",          -- Ruby/Go dependencies
  },
})
```

### Configuration Options Explained

#### Layout Options

- **`"tab"`** (default): Opens all files as vertical splits in a new tab
- **`"vsplit"`**: Opens each file in a new vertical split
- **`"split"`**: Opens each file in a new horizontal split
- **`"floating"`**: Opens each file in a floating window
- **`"quickfix_list"`**: Populates the quickfix list with all stack trace entries

#### Exclude Patterns

The `exclude_patterns` option filters out unwanted files from stack traces, particularly useful for hiding third-party dependencies and system libraries:

- **`table`** (default): List of Lua patterns to match against absolute file paths
- **`false`**: Disable filtering entirely (show all files from stack trace)

Common patterns included by default:

- `node_modules` - JavaScript/TypeScript dependencies
- `.venv`, `venv` - Python virtual environments
- `site%-packages`, `dist%-packages` - Python installed packages
- `/usr/`, `/lib/` - System libraries
- `%.cargo/` - Rust dependencies
- `vendor/` - Ruby/Go dependencies

You can customize this list to match your project needs:

```lua
require("nvim-unstack").setup({
  -- Only exclude node_modules
  exclude_patterns = { "node_modules" },

  -- Or disable filtering completely
  exclude_patterns = false,
})
```

#### Multiple Parser Matching

The `use_first_parser` option controls behavior when multiple parsers can parse the same stack trace:

- **`true`** (default): Automatically uses the first matching parser
- **`false`**: Shows a selection prompt with parser names (e.g., "Python", "Pytest", "Node.js")

This is particularly useful for Python projects where both standard Python tracebacks and Pytest output might be present. Each parser has a descriptive name to help you choose the right one.

#### Visual Signs

When `showsigns = true`, nvim-unstack will place visual indicators (`>>`) next to the lines referenced in the stack trace, making them easy to spot.

#### Debug Mode

Enable `debug = true` to see detailed logging about:

- Which language parser was selected
- What files and line numbers were extracted
- Any parsing errors or warnings

## 🧰 Commands

nvim-unstack provides several commands for different use cases:

| Command                 | Description                                     |
| ----------------------- | ----------------------------------------------- |
| `:NvimUnstack`          | Parse stack trace from current visual selection |
| `:UnstackFromClipboard` | Parse stack trace from system clipboard         |
| `:UnstackFromTmux`      | Parse stack trace from tmux paste buffer        |

### Command Usage Examples

```vim
" Parse visual selection (or use the default <leader>s keymap)
:'<,'>NvimUnstack

" Parse from clipboard
:UnstackFromClipboard

" Parse from tmux buffer
:UnstackFromTmux
```

## 🔧 API

nvim-unstack provides a Lua API for programmatic usage:

### Core Functions

```lua
local nvim_unstack = require("nvim-unstack")

-- Parse and open files from visual selection
nvim_unstack.unstack()

-- Parse from system clipboard
nvim_unstack.unstack_from_clipboard()

-- Parse from tmux paste buffer
nvim_unstack.unstack_from_tmux()

-- Setup with custom configuration
nvim_unstack.setup({
  layout = "floating",
  mapkey = "<leader>u"
})
```

### Advanced Usage

```lua
-- Custom keymapping examples
vim.keymap.set("v", "<leader>u", function()
  require("nvim-unstack").unstack()
end, { desc = "Unstack visual selection" })

vim.keymap.set("n", "<leader>uc", function()
  require("nvim-unstack").unstack_from_clipboard()
end, { desc = "Unstack from clipboard" })

vim.keymap.set("n", "<leader>ut", function()
  require("nvim-unstack").unstack_from_tmux()
end, { desc = "Unstack from tmux" })
```

## 🎨 Customization

### Adding New Language Parsers

You can extend nvim-unstack to support additional languages by creating custom regex parsers. Here's the structure:

```lua
-- Example: Custom Java parser
-- Save to nvim-unstack/regex

local java = {}

-- Display name for parser selection prompt
java.name = "Java"

-- Regex pattern to match Java stack trace lines
java.regex = vim.regex([[at .*(\(.*\.java:[0-9]\+\))]])

-- Function to extract file and line numbers from entire traceback text
function java.extract_matches(text)
    local matches = {}

    -- Match Java stack trace format
    for file, line_num in text:gmatch("%((.*)%.java:([0-9]+)%)") do
        table.insert(matches, { file .. ".java", line_num })
    end

    return matches
end

return java
```

**Note:** The `name` field is required for displaying the parser in the selection prompt when `use_first_parser = false`.

### Custom Layout Configurations

You can create wrapper functions for specific layout preferences:

```lua
-- Quick functions for different layouts
local function unstack_floating()
    local original_layout = require("nvim-unstack.config").options.layout
    require("nvim-unstack.config").options.layout = "floating"
    require("nvim-unstack").unstack()
    require("nvim-unstack.config").options.layout = original_layout
end

-- Create custom commands
vim.api.nvim_create_user_command("UnstackFloat", unstack_floating, {})
```

### Sign Customization

Customize the appearance of stack trace line indicators:

```lua
require("nvim-unstack").setup({
  showsigns = true
})

-- Override sign appearance after setup
vim.fn.sign_define("UnstackLine", {
    text = "▶",
    texthl = "DiagnosticError",
    linehl = "CursorLine",
})
```

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🗞 Wiki

You can find guides and showcase of the plugin on [the Wiki](https://github.com/relf108/nvim-unstack/wiki)

## 🎭 Motivations

After using (and loving) [mattboehm's vim-unstack](https://github.com/mattboehm/vim-unstack) for about a year I've collected a short list of gripes that I think are worth taking the time to fix, unfortunately the repo is no longer maintained so I've decided to rip out the regex and rewrite it in Lua.

- Lack of configurability, it's v-splits or nothin' pal and god help you if you want line numbers in those splits.
- Not extendable, stack trace parsing is incredibly useful in a wide array of languages and it should be easy for users of the plugin to add their favourites.
- Written in vimscript, this is fine and the plugin still works in neovim but it creates a barrier to entry when trying to contribute code and I think the Lua ecosystem has a lot to offer.
