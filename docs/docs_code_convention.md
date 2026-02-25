
# 📘 Code conventions  <!-- omit from toc -->

- [Formatting](#formatting)
- [Naming conventions](#naming-conventions)
	- [Signal names](#signal-names)
	- [Some methods names start with `__`](#some-methods-names-start-with-__)
- [Code order](#code-order)
- [Static Typing](#static-typing)

## Formatting

Follow official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#formatting).

**Godot-tools** does not support all the necessary formatting.
That's why it can be hard to follow the formatting guidelines.
E.g:

- does note make 2 empty lines padding between functions (uses 1 line)
- ignores indentations like [this](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#indentation) (both good and bad will be passed)
- has bugs. Examples are
  - Recently started to add redundant space like this: `call_func(self )` [link](https://github.com/godotengine/godot-vscode-plugin/issues/972)
  - Some problem with `@abstract` keyword for inner classes,[see](../logic/c_systems/character_sm/player_sm/model/_meta_state.gd)

## Naming conventions

Follow official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#naming-conventions) with some exceptions below.

### Signal names

We use `SIG_` prefix for signal names. See [docs_signal](docs_signal.md)

### Some methods names start with `__`

'Infrastructure' method names starts with double underscore `__` (kinda like python magic methods).
Currently these are **Validation** and **Logger Frameworks** (link to come)

## Code order

Follow official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#code-order) with exceptions/additions:

- Inner classes are placed above the methods (seems natural)
- **Validation Framework** methods are placed above all other methods (technical and important)
- These groups of methods are placed below all other methods (order follows bullet points order)
   - signal handlers (interrupts code flow)
   - overridden `_input` like methods (interrupts code flow)
   - any dev/debug methods which are not part of the business logic _(while we try to separate them from main files entirely)_
   - **Logger Framework** methods (least important)

Also note about the [class declaration](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#class-declaration): `@tool` keyword is often used just to make an icon

- It helps with readability (Godot UI) greatly
- Probably is a bad practice: engine tries to run them all in editor (being blocked by [link to come]).
- => Unfortunately should be deleted in the future.

## Static Typing

Follows official [docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#static-typing)

- All code should be statically typed (unless it's not supported by gdscript, like nested arrays or variadic arguments).
- This includes typing `Dict` and `Array` elements
- Some exceptions are made for workflow scripts (e.g. post import script) and Frameworks (e.g. log functions are mostly untyped)
- Using 'type specific' built-ins are encouraged (`absf()` instead of `abs()`), as well as writing custom utils with the same idea in mind
