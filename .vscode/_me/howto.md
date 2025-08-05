## Extension folder
%USERPROFILE%\.vscode\extensions

macOS/Linux:
~/.vscode/extensions


## Color folders extension
extansion: %USERPROFILE%\.vscode\extensions\visbydev.folder-path-color-0.0.15
*i changed .js and package.json. copy saved in _me*


## Godot theme extension
name: ryanabx.godot-vscode-theme-0.0.5 extension

*i changed some colors. copy saved in _me*


## Keymap
copy is in _me


## vscode
for info about colors and scopes: scope
for reloading: developer reload



## Copilot

Choosing models
[text](https://docs.github.com/en/copilot/reference/ai-models/model-comparison#recommended-models-by-task)

Ctrl+. (Control + period).
This shortcut will present a lightbulb icon or a menu with available actions relevant to your current cursor position or selected code, including suggestions from Copilot if applicable.
Additionally, for interacting with Copilot Chat features:
Ctrl+I: opens Inline Chat directly within the editor or integrated terminal.
Ctrl+Alt+I: opens the dedicated Chat view.

Alternatively, use the Snooze Inline Suggestions and Cancel Snooze Inline Suggestions commands in the Command Palette.

Code completions settings
github.copilot.enable - enable or disable inline completions for all or specific languages.

editor.inlineSuggest.fontFamily - configure the font for the inline completions.

editor.inlineSuggest.showToolbar - enable or disable the toolbar that appears for inline completions.

editor.inlineSuggest.syntaxHighlightingEnabled - enable or disable syntax highlighting for inline completions.

Next edit suggestions settings
github.copilot.nextEditSuggestions.enabled - enable Copilot next edit suggestions (Copilot NES).

editor.inlineSuggest.edits.allowCodeShifting - configure if Copilot NES is able to shift your code to show a suggestion.

editor.inlineSuggest.edits.renderSideBySide - configure if Copilot NES can show larger suggestions side-by-side if possible, or if Copilot NES should always show larger suggestions below the relevant code.
	* auto (default): show larger edit suggestions side-by-side if there is enough space in the viewport, otherwise the suggestions are shown below the relevant code.
	* never: never show suggestions side-by-side, always show suggestions below the relevant code.