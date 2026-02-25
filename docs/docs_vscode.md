# VScode Docs <!-- omit from toc -->

- [Why VSCode](#why-vscode)
- [🧩 Extensions](#-extensions)
	- [Extension list](#extension-list)
	- [Extension folder](#extension-folder)
- [🔷 Working with VSCode](#-working-with-vscode)
	- [Working with file view](#working-with-file-view)
	- [Global Code Renaming](#global-code-renaming)
- [💡 Tips](#-tips)
	- [Commands](#commands)
	- [Can be excluded from search while working](#can-be-excluded-from-search-while-working)
	- [Regex searches (typings cleanup)](#regex-searches-typings-cleanup)
	- [Custom Keymap](#custom-keymap)
- [👨‍🔧 Troubleshooting](#-troubleshooting)

## Why VSCode

Native Godot code editor is fine for small code snippets and learning purposes, but Godot is a game engine and not an IDE, it naturally lacks many features:

- No multi window support (splitting tabs). Also no tab management like pinning tabs (and there are located vertically!)
- No global code renamings (while LSP and godot-tool support this, see instruction: [docs_vscode](docs_vscode.md#global-code-renaming)).
- From my experience, [Version Control plugin](https://github.com/godotengine/godot-git-plugin) breaks on every project reload and has some other issues.
- No code formatting (godot-tools has this while with limitations).
- VSCode is just much faster. Even basic actions like code typing or file view scrolling have a noticeble lag in Godot.
- Access to all the extensions. Assume you decided to add a markdown linter to your project. In Godot this is probably can't be done, in VSCode this is a usual IDE one minute routine. See recommended extensions below.

UPD: Formatting problem is probably solved: [gdscript_formatter](https://www.gdquest.com/library/gdscript_formatter/)

Of course there are downsides:

- Code is separated from essential Godot windows like Inspector or Scene tree. This leads to lack of cool features like drag and dropping node reference as an @onready variable.
- You don't see many of usdeful UI hints. Auto completion inside built-in code editor may show Node icons, also there would be a visual hint if a method is connected to signal via UI;
- You [**can't**](docs_vscode.md#working-with-file-view) make any changes to file system using VSCode file view.  
- Godot-tools LSP connection and running/debugging features are very robust, but it still adds a layer between you and the engine, which comes with some bugs and additional latency (speed of VSCode itself should compensate for it)
- Naturally godot-tools is "catching up" after the releases of the engine, not the other way around. This is noticeble when new GDScript syntax features are introduced (while it does not happen often).
- You manage two apps instead of one. In case of working with one monitor it may become an issue.

## 🧩 Extensions

### Extension list

Necessary extensions:

- [godot-tools](https://github.com/godotengine/godot-vscode-plugin).
	- Integration with Godot Engine via LSP, debugger, formatter

Useful godot extensions:

- [godot-files](https://marketplace.visualstudio.com/items?itemName=alfish.godot-files)
- [godot-tab-formatter](https://marketplace.visualstudio.com/items?itemName=justburntpixels.godot-tab-formatter)

Other useful extensions:

- [vscode-highlight](https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-highlight)
  - helps to solve godot-tools bugs like [with abstract color](https://github.com/godotengine/godot-vscode-plugin/issues/962#issuecomment-3905152966)
  - helps to make some systems stand out, most noticeable is a Validation Framework (link to come)
- [error lens](https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens)
  - useful for seeing errors

Example of extension settings can be found [here](../.vscode/settings.json)

### Extension folder

`%USERPROFILE%\.vscode\extensions`

macOS/Linux:
`~/.vscode/extensions`

## 🔷 Working with VSCode

### Working with file view

⚠️ Don't do any write operations of file system via VSCode.

On every file change Godot recalculates dependencies and sometimes adds/deletes files UIDs. This can only be done when using File System UI interface in Godot.

Changing file structure via VSCode equals to changing it using OS File System. This leads to broken dependencies, scripts being unattached from nodes, incorrect UIDs and sometimes even a file duplication.

### Global Code Renaming

ℹ️ Interestingly, I couldn't found this feature in built-in Godot Editor.

Godot-tools supports global renaming of entity names like vars, classes and functions. This can be done via F2 key or **RenameSymbol** option (confusing name).

Code namespaces are being preserved: renaming function parameter from `a` to `b` does not mean that all `a` will be renamed across the whole project.

Still, false positives (and sometimes negatives) may occur.
Most notable example is when you rename a function name (not function parameter or inner variable), all the mentions of this name _in comments_ will be renamed as well. This can be handy, but also deceiving:

```GDScript
# TestClass.waiting() helps you to wait
# "waiting for godot" is a tragicomedy play first published in 1952

func waiting():
	pass
```

Let's renaming `func waiting()` to `async_waiting`. The result:

```GDScript
# TestClass.async_waiting() helps you to wait
# "async_waiting for godot" is a tragicomedy play first published in 1952

func async_waiting():
	pass
```

Conclusion:

- Very useful for things like renaming base classes or function parameters
- Pretty good for narrow scopes (function variable) and for big and unambiguous names (`awake_knight_artorias`).
- ⚠️ Generic and short names may cause hundreds of unrelated false positives across the project.
- False negatives are not super rare as well.
- => Always verify diff changes before committing the result.

## 💡 Tips

### Commands

- info about colors and scopes: command `scope`
- reloading: command `developer reload window`

### Can be excluded from search while working

`_dev/**, addons/**, ideas*, *.godot, *.tscn*, *.import, *.git, *.tres`

### Regex searches (typings cleanup)

- `var \w+ =`
- `func \w+\(\):`
- `^\s*func\s+.*?[,(]\s*\b\w+\b\s*(?![=:])(?=[,)])`

### Custom Keymap

Copy is in .vscode/custom folder

## 👨‍🔧 Troubleshooting

⚠️ on updating or moving godot.exe change 'godotTools.editorPath.godot4' in settings!
