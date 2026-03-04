# VScode Docs 🔷 <!-- omit from toc -->

- [🤔 Why VSCode](#-why-vscode)
- [🧩 Extensions](#-extensions)
	- [Extension list](#extension-list)
		- [Necessary](#necessary)
		- [Optional](#optional)
	- [Extension folder](#extension-folder)
- [✍️ VSCode instructions](#️-vscode-instructions)
	- [Working with file view](#working-with-file-view)
	- [Global Code Renaming](#global-code-renaming)
- [💡 Tips](#-tips)
	- [Commands](#commands)
	- [Can be excluded from search](#can-be-excluded-from-search)
	- [Regex searches (typings cleanup)](#regex-searches-typings-cleanup)
	- [Custom Keymap](#custom-keymap)
- [👨‍🔧 Troubleshooting](#-troubleshooting)

## 🤔 Why VSCode

> [!NOTE]
> Almost all of the pros and cons listed here can be applied to any IDE, not just VSCode. But I haven't tried others, like [Rider](https://www.jetbrains.com/lp/rider-godot/)

Native Godot code editor is fine for small code snippets and learning purposes, but Godot is a game engine and not an IDE. It naturally lacks many features:

- No multi window support (splitting tabs). Also no tab management like pinning tabs (and there are located vertically!)
- No global code refactoring (while LSP and **godot-tool** support this, see instruction: [docs_vscode](docs_vscode.md#global-code-renaming)).
- From my experience, [Version Control plugin](https://github.com/godotengine/godot-git-plugin) might break on project reload and has some other issues.
- No code formatting (**godot-tools** has this while with limitations).
- Ability to work with textual representation of essential Godot files like `.tscn` or `.tres` as well as with files which Godot does not support like blender `.py` scripts
- VSCode is just much faster. Even basic actions like code typing or file view scrolling have a noticeable lag in Godot.
- Extensions. Assume you decided to add a markdown linter or a spell checker. In Godot this is probably can't be done, in VSCode this is a usual IDE routine.

Of course there are downsides:

- Code is separated from essential Godot windows like Inspector or Scene tree. This leads to lack of cool features like drag and dropping node reference as an `@onready` variable.
- You lose useful UI hints. Auto completion inside Godot may show Node icons, also there is a visual hint if a method is connected to signal via UI.
- You [**can't**](docs_vscode.md#working-with-file-view) make any changes to file system using VSCode file view.  
- **Godot-tools** LSP connection and running/debugging features are very robust, but it still adds a layer between you and the engine, which comes with bugs (common), sync issues (rare) and additional latency (should be compensated by VSCode agility)
- Naturally **godot-tools** is "catching up" after the releases of the engine. This is noticeable when new GDScript syntax features are introduced (while it does not happen often).
- Managing two apps instead of one. In case of working with one monitor it may become an issue.

> [!IMPORTANT]
> UPD: Formatting problem is solved: [gdscript_formatter](https://www.gdquest.com/library/gdscript_formatter/)

## 🧩 Extensions

### Extension list

#### Necessary

- [godot-tools](https://github.com/godotengine/godot-vscode-plugin).
	- Integration with Godot Engine via LSP, debugger, formatter

#### Optional

🦾 - recommended; ✍️ - just QoL

Godot extensions:

- 🦾 [godot-files](https://marketplace.visualstudio.com/items?itemName=alfish.godot-files)
- ✍️ [godot-tab-formatter](https://marketplace.visualstudio.com/items?itemName=justburntpixels.godot-tab-formatter)
- ✍️ [godot theme](https://marketplace.visualstudio.com/items?itemName=JamesSauer.gdscript-theme)

Markdown extensions:

- 🦾 [markdown-all-in-one](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
  - auto creates table of contents
  - used in docs/
- 🦾 [markdown-lint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
  - auto formatting on Ctrl-S (not annoying if muting several errors)
  - used in docs/
- ✍️ [markdown-preview-github-styles](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles)
- ✍️ [md table prettify](https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify)

Other:

- 🦾 [vscode-highlight](https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-highlight)
  - helps to solve godot-tools bugs like [with `@abstract` color](https://github.com/godotengine/godot-vscode-plugin/issues/962#issuecomment-3905152966)
  - helps to make some systems stand out, e.g. used for [Validation Framework](docs_project_systems/docs_validation_framework.md)
- 🦾 [Copy Path (Unix Style)](https://marketplace.visualstudio.com/items?itemName=baincd.copy-path-unixstyle)
  - must have for windows
- 🦾 [error lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
  - useful for seeing errors
- ✍️ [spell checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
- ✍️ [Colorful folders](https://marketplace.visualstudio.com/items?itemName=VisbyDev.folder-path-color)
  - you may wish to synchronize ur fancy colorful folders between Godot and VSCode

Example of extension settings can be found [here](../.vscode/settings.json)

### Extension folder

`%USERPROFILE%\.vscode\extensions`

macOS/Linux:
`~/.vscode/extensions`

## ✍️ VSCode instructions

### Working with file view

⚠️ Don't do any changes to file system via VSCode.

On every file change Godot recalculates dependencies and sometimes adds/deletes files UIDs. This can only be done via File System UI interface in Godot.

Changing file structure via VSCode equals to changing it using OS file system. This leads to broken dependencies, scripts being unattached from nodes, incorrect UIDs and sometimes even a file duplication.

### Global Code Renaming

ℹ️ Somehow I couldn't found this feature in built-in Godot Editor.

**Godot-tools** supports global renaming of entity names like vars, classes and functions. This can be done via F2 key or **RenameSymbol** option (confusing name).

Code namespaces are being preserved: renaming function parameter from `a` to `b` does not mean that all `a` will be renamed across the whole project.

Still, false positives (and sometimes negatives) may occur.

⚠️ Notable example is when you rename a function, _all the mentions of this name inside string values and comments_ will be renamed as well. This can be handy, but also deceiving:

```GDScript
# TestClass.waiting() helps you to wait
# "waiting for godot" is a tragicomedy play first published in 1952

const default_state = "waiting"
const second_state = "waiting for godot"
const third_state = "awaiting"

func waiting():
	pass
```

Let's rename `func waiting()` to `async_waiting`.
✔️ - expected change. ❌ - false positive.

```GDScript
# TestClass.async_waiting() helps you to wait ✔️
# "async_waiting for godot" is a tragicomedy play first published in 1952 ❌

const default_state = "async_waiting" # probably ❌
const second_state = "async_waiting for godot" # ❌
const third_state = "awaiting" # ✔️ (only this line hasn't changed)

func async_waiting(): # obviously ✔️
	pass
```

This means that such renaming depends on not language semantics, but also just pattern matching. _This makes me think that this is VSCode bug, not Godot's (need to check)_

Conclusion:

- Very useful for things like renaming base classes or function parameters
- Pretty good for narrow scopes (function variable) and for big and unambiguous names (`awake_knight_artorias`).
- ⚠️ Renaming generic and short names may cause hundreds of unrelated false positives across the project.
- False negatives also can occur.
- => **Always verify diff changes before committing the result.**

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

## 👨‍🔧 Troubleshooting

⚠️ On updating or moving godot.exe change `godotTools.editorPath.godot4` in settings!
