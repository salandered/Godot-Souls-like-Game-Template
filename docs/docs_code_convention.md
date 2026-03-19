
# 📘 Code conventions  <!-- omit from toc -->

- [Formatting](#formatting)
- [Naming conventions](#naming-conventions)
	- [Signal names](#signal-names)
	- [Some methods names start with `__`](#some-methods-names-start-with-__)
- [Code order](#code-order)
- [Static Typing](#static-typing)

## Formatting

Follow official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#formatting).

> [!IMPORTANT]
> UPD: New official formatter: [gdscript_formatter](https://www.gdquest.com/library/gdscript_formatter/)

**Godot-tools** does not support all the necessary formatting, so it sometimes hard to follow the official docs.
E.g:

- Does note make 2 empty lines padding between functions (uses 1 line)
- Ignores indentations like [this](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#indentation) (both good and bad will be passed)
- Has bugs. Examples:
  - Recently started to add redundant space like this: `call_func(self )` [link](https://github.com/godotengine/godot-vscode-plugin/issues/972)
  - Some problem with `@abstract` keyword for inner classes, [see meta state code](../logic/systems/character_sm/player_sm/model/_meta_state.gd)

## Naming conventions

Follow official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#naming-conventions) with some exceptions below.

### Signal names

We use `SIG_` prefix for signal names. See [docs_signal](docs_signal.md)

### Some methods names start with `__`

Framework method names start with double underscore `__` (kinda like python magic methods).
Currently these are [Logger](docs_project_systems/docs_logging_framework) and [Validation](docs_project_systems/docs_validation_framework.md) frameworks.

## Code order

Follow official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#code-order) with exceptions/additions:

- Inner classes are placed above the methods (seems natural)
- **Validation Framework** method implementations are placed above all other methods _(important dependency info)_
- These groups of methods are placed below all other methods (order follows bullet points order)
   - signal handlers _(interrupts code flow)_
   - overridden `_input` like methods _(interrupts code flow)_
   - any dev/debug methods which are not part of the business logic _(while we try to separate them from main files entirely)_
   - **Logger Framework** methods _(least important)_

ℹ️ Note about the [class declaration](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#class-declaration): `@tool` keyword is often used just to make an icon

- It helps with readability (Godot UI) greatly
- Probably is a bad practice: engine tries to run them all in editor (being blocked by utilities).
- => Unfortunately should be deleted in the future.

## Static Typing

Follows official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#static-typing)

- All code should be statically typed (unless it's not supported, like nested arrays or variadic arguments).
- This includes typing `Dict` and `Array` elements
- Some exceptions are made for workflow scripts (e.g. post import script) and Frameworks (e.g. log functions are mostly untyped)
- Using 'type specific' built-ins are encouraged (`absf()` instead of `abs()`), as well as writing custom utils with the same idea in mind
