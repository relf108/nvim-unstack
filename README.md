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
  <h1 align="center">nvim-unstack</h2>
</p>

<p align="center">
    A powerful Neovim plugin for parsing and navigating stack traces from multiple programming languages.
</p>

<p align="center">
    Quickly jump to files and line numbers from stack traces with configurable layouts and visual indicators.
</p>

## ⚡️ Features

- **Multi-language support**: Built-in regex parsers for Python, Node.js, Ruby, Go, C#, Perl, and GDB/LLDB
- **Flexible layouts**: Open files in tabs, vertical splits, horizontal splits, or floating windows
- **Visual indicators**: Optional signs to highlight stack trace lines
- **Multiple input methods**: Parse from visual selection, clipboard, or tmux paste buffer
- **Configurable keymaps**: Customize the key binding for stack trace parsing
- **Easy extension**: Simple API for adding custom language parsers
- **Zero dependencies**: Pure Lua implementation with no external requirements

## 🎯 Supported Languages

nvim-unstack comes with built-in support for parsing stack traces from:

- **Python** - Standard Python tracebacks with file paths and line numbers
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
  config = function()
    require("nvim-unstack").setup({
      -- Your configuration here
    })
  end
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
  -- Options: "tab", "vsplit", "split", "floating"
  layout = "tab",

  -- Key mapping for visual selection unstacking (default: "<leader>s")
  mapkey = "<leader>s",

  -- Show signs on lines from stack trace (default: true)
  showsigns = true,

  -- Vertical alignment for splits (default: "topleft")
  -- Options: "topleft", "topright", "bottomleft", "bottomright"
  vertical_alignment = "topleft",
})
```

### Configuration Options Explained

#### Layout Options

- **`"tab"`** (default): Opens all files as vertical splits in a new tab
- **`"vsplit"`**: Opens each file in a new vertical split
- **`"split"`**: Opens each file in a new horizontal split
- **`"floating"`**: Opens each file in a floating window

#### Visual Signs

When `showsigns = true`, nvim-unstack will place visual indicators (`>>`) next to the lines referenced in the stack trace, making them easy to spot.

#### Debug Mode

Enable `debug = true` to see detailed logging about:

- Which language parser was selected
- What files and line numbers were extracted
- Any parsing errors or warnings

### Advanced Configuration

<details>
<summary>Complete configuration with all options</summary>

```lua
require("nvim-unstack").setup({
  debug = false,
  layout = "tab",
  mapkey = "<leader>s",
  showsigns = true,
  vertical_alignment = "topleft",
})
```

</details>

## 🧰 Commands

nvim-unstack provides several commands for different use cases:

| Command                 | Description                                     |
| ----------------------- | ----------------------------------------------- |
| `:NvimUnstack`          | Parse stack trace from current visual selection |
| `:UnstackFromClipboard` | Parse stack trace from system clipboard         |
| `:UnstackFromTmux`      | Parse stack trace from tmux paste buffer        |
| `:NvimUnstackEnable`    | Enable the plugin                               |
| `:NvimUnstackDisable`   | Disable the plugin                              |
| `:NvimUnstackToggle`    | Toggle the plugin on/off                        |

### Command Usage Examples

```vim
" Parse visual selection (or use the default <leader>s keymap)
:'<,'>NvimUnstack

" Parse from clipboard
:UnstackFromClipboard

" Parse from tmux buffer
:UnstackFromTmux

" Toggle plugin state
:NvimUnstackToggle
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

-- Plugin control
nvim_unstack.enable()
nvim_unstack.disable()
nvim_unstack.toggle()

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

local java = {}

-- Regex pattern to match Java stack trace lines
java.regex = vim.regex([[at .*(\(.*\.java:[0-9]\+\))]])

-- Function to extract file and line number from matched line
function java.format_match(line, lines, index)
    local file = line:match("%((.*)%.java:")
    local line_num = line:match(":([0-9]+)%)")

    if file and line_num then
        return { file .. ".java", line_num }
    end

    return nil
end

return java
```

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
