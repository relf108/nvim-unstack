<!--toc:start-->

- [⚡️ Features](#️-features)
- [📋 Installation](#-installation)
- [☄ Getting started](#-getting-started)
- [⚙ Configuration](#-configuration)
- [🧰 Commands](#-commands)
- [⌨ Contributing](#-contributing)
- [🗞 Wiki](#-wiki)
- [🎭 Motivations](#-motivations)
<!--toc:end-->

<p align="center">
  <h1 align="center">nvim-unstack</h2>
</p>

<p align="center">
    Parse stack traces from a variety of languages in neovim.
</p>

<div align="center">
    > Drag your video (<10MB) here to host it for free on GitHub.
</div>

<div align="center">

> Videos don't work on GitHub mobile, so a GIF alternative can help users.

_[GIF version of the showcase video for mobile users](SHOWCASE_GIF_LINK)_

</div>

## ⚡️ Features

- Jump to lines printed to stack traces.
- Built in regex for a range of languages.
- Easily extend language support via local config.
- Configure files referenced in stack traces to be opened as v-splits, h-splits, distinct tabs or even a floating window.

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

```lua
-- stable version
use {"nvim-unstack", tag = "*" }
-- dev version
use {"nvim-unstack"}
```

</td>
</tr>
<tr>
<td>

[junegunn/vim-plug](https://github.com/junegunn/vim-plug)

</td>
<td>

```lua
-- stable version
Plug "nvim-unstack", { "tag": "*" }
-- dev version
Plug "nvim-unstack"
```

</td>
</tr>
<tr>
<td>

[folke/lazy.nvim](https://github.com/folke/lazy.nvim)

</td>
<td>

```lua
-- stable version
require("lazy").setup({{"nvim-unstack", version = "*"}})
-- dev version
require("lazy").setup({"nvim-unstack"})
```

</td>
</tr>
</tbody>
</table>
</div>

## ☄ Getting started

To use the plugin after installation simply visual select a stack trace (or part of one) and use `<leader>s` to open the referenced files.

## ⚙ Configuration

<details>
<summary>Click to unfold the full list of options with their default values</summary>

> **Note**: The options are also available in Neovim by calling `:h nvim-unstack.options`

```lua
require("nvim-unstack").setup({
    -- you can copy the full list from lua/nvim-unstack/config.lua
})
```

</details>

## 🧰 Commands

| Command   | Description         |
| --------- | ------------------- |
| `:Toggle` | Enables the plugin. |

## ⌨ Contributing

PRs and issues are always welcome. Make sure to provide as much context as possible when opening one.

## 🗞 Wiki

You can find guides and showcase of the plugin on [the Wiki](https://github.com/relf108/nvim-unstack/wiki)

## 🎭 Motivations

After using (and loving) [mattboehm's vim-unstack](https://github.com/mattboehm/vim-unstack) for about a year I've collected a short list of gripes that I think are worth taking the time to fix, unfortunately the repo is no longer maintained so I've decided to rip out the regex and rewrite it in Lua.

- Lack of configurability, it's v-splits or nothin' pal and god help you if you want line numbers in those splits.
- Not extendable, stack trace parsing is incredibly useful in a wide array of languages and it should be easy for users of the plugin to add their favourites.
- Written in vimscript, this is fine and the plugin still works in neovim but it creates a barrier to entry when trying to contribute code and I think the Lua ecosystem has a lot to offer.
