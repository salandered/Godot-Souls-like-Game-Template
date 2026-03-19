# VScode Docs 🔷 <!-- omit from toc -->

- [About VSCode](#about-vscode)
- [🧩 Extensions](#-extensions)
	- [Extensions List](#extensions-list)
	- [Extension folder](#extension-folder)
- [💡 Tips](#-tips)
	- [Commands](#commands)
	- [Can be excluded from search](#can-be-excluded-from-search)
	- [Regex searches (typings cleanup)](#regex-searches-typings-cleanup)
	- [Custom Keymap](#custom-keymap)

## About VSCode

My blog post about [Godot and VSCode](https://salandered.github.io/posts/godot-and-vscode/) applies to this project.

## 🧩 Extensions

### Extensions List

Essential extensions are listed in [here](https://salandered.github.io/posts/godot-and-vscode/#vscode-extensions-for-working-with-godot).

Markdown extensions:

- 🦾 [markdown-all-in-one](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
  - auto creates table of contents
  - used in docs/
- 🦾 [markdown-lint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
  - auto formatting on Ctrl-S (not annoying if muting several errors)
  - used in docs/
- ✍️ [markdown-preview-github-styles](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles)
- ✍️ [md table prettify](https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify)

- ✍️ [spell checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)

### Extension folder

`%USERPROFILE%\.vscode\extensions`

macOS/Linux:
`~/.vscode/extensions`

## 💡 Tips

### Commands

- info about colors and scopes: command `scope`
- reloading: command `developer reload window`

### Can be excluded from search

> [!NOTE]
> Being able to search through `.tscn` or `.tres` can be very useful

`_dev/**, addons/**, *.godot, *.tscn*, *.import, *.git, *.tres`

### Regex searches (typings cleanup)

- `var \w+ =`
- `func \w+\(\):`
- `^\s*func\s+.*?[,(]\s*\b\w+\b\s*(?![=:])(?=[,)])`

### Custom Keymap

Copy is in .vscode/custom folder
