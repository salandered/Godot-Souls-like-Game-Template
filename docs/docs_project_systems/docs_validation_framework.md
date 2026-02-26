# Validation Framework 🛡️ <!-- omit from toc -->

- [🧾 What it does](#-what-it-does)
- [🔌 Framework API](#-framework-api)
	- [Methods to Implement](#methods-to-implement)
	- [Methods to Call](#methods-to-call)
- [🎛️ Usage Examples](#️-usage-examples)
	- [Simplest usage with one hard dependency](#simplest-usage-with-one-hard-dependency)
	- [Custom validation](#custom-validation)
	- [Blocking important functions](#blocking-important-functions)
	- [Disabling process](#disabling-process)
	- [Nested Custom Classes](#nested-custom-classes)
- [🦾 Real examples](#-real-examples)
- [💡 Tips](#-tips)
- [🤔 Ideas Behind Implementation and Trade-offs](#-ideas-behind-implementation-and-trade-offs)
	- [Why this is acceptable](#why-this-is-acceptable)
	- [Alternative via composition](#alternative-via-composition)
		- [Problems](#problems)
		- [Future Proofing](#future-proofing)

## 🧾 What it does

The Validation Framework:

- **Runs dependency validation** and any custom validation for any custom class used in code. (in Godot it means all the files except for may be `EditorScript`).
- **Persists the validation result** and produces API for a custom class to check the validation result
- It also can automatically disable the node if validation is failed.

It evaluates both "hard" (critical) and "soft" (optional) dependencies and also any custom logic that custom class might need.

Validation part is meant to run on initialisation of any class (e.g. inside `_ready`)

Result of validation can be accessed any time, e.g. you can add a check of your `_process` function or public api of the class.

This makes validation centralized and unified for any component, and makes system fault tolerant:

- any failed component knows about it and "embraces" the situation.
- framework itself tolerates any possible error and prints all the gathered info.

## 🔌 Framework API

To use the framework, your custom class should extend a so-called "built-in class extender" (e.g. `NodeSystem`) rather than a base Godot class (like `Node`) directly. This extender provides the validation API and base methods to implement which will be used for validation.

Custom class may choose which methods to implement based on its needs.
Currently it can fully ignore framework functionality, while it's planned in the future to force framework usage.

### Methods to Implement

Class defines its dependencies and things to validate by overriding the following methods:

- `__hard_dependencies() -> Array`: Returns an array of critical objects that must not be null.

- `__soft_dependencies() -> Array`: Returns an array of optional objects.

- `__hard_validation() -> bool`: Returns a boolean based on critical custom logic checks.

- `__soft_validation() -> bool`: Returns a boolean based on optional custom logic checks.

### Methods to Call

You should call these methods from your custom class:

- `__perform_validation(process_disable_on_fail: bool = false) -> bool`: Performs the actual validation. Implemented methods will be implicitly used. Call this inside your initialization method (like `_ready` or `initialise`). It returns the result and also persists it so custom class can access it later.

- `__validation_ok() -> bool`: Returns the result of the `__validated` flag. Use this in your `_process` or public API methods to ensure the custom class is safe to be used.

NOTE: failing of soft dependencies or soft validation results in successful validation, but all the problems will be listed in logs.

## 🎛️ Usage Examples

### Simplest usage with one hard dependency

```GDScript
class_name MyCustomSystem
extends NodeSystem

var required_marker: Marker3D

func __hard_dependencies() -> Array:
	return [required_marker]

func _ready_() -> void:
	if not __perform_validation():
		print("MyCustomSystem dependencies are not met, won't be working)
		return
	...
```

### Custom validation

```GDScript
func __hard_validation() -> bool:
	return required_marker.name == "MyMarker"
```

### Blocking important functions

This makes any other system around `MyCustomSystem` fault tolerant.

```GDScript
func _process(delta: float) -> void:
	if not __validation_ok():
		return
	...

## public api
func move_marker(): 
	if not __validation_ok():
		print("sorry can't do that")
		return
	required_marker.position.y += 10
```

### Disabling process

```GDScript
func _ready_() -> void:
	if not __perform_validation():
		set_process(false)
		print("MyCustomSystem dependencies are not met, won't be working at all)
		return

func _ready_() -> void:
	if not __perform_validation(true): # <- OR auto disabling process  
		print("MyCustomSystem dependencies are not met, won't be working at all)
		return
```

### Nested Custom Classes

Append your new dependencies using `super`:

```GDscript
class_name MyCustomSystem
extends NodeSystem

var required_marker: Marker3D

func __hard_dependencies() -> Array:
	return [required_marker]


class_name DerivedCustomSystem
extends MyCustomSystem

var another_marker: Marker3D

func __hard_dependencies() -> Array:
	return super.__hard_dependencies() + [
		another_marker
	]
```

## 🦾 Real examples

They can be found anywhere in project, e.g:

- [_common_area](../logic/c_systems/common_area/_common_area.gd)
- [dv_bus_spectrum](../logic/x_dev_systems/audio_visualiser/dv_bus_spectrum.gd)
- [pl_char](../logic/c_systems/character/pl_char.gd)

## 💡 Tips

**Syntax Highlighting:** It is highly recommended to use the `vscode-highlight` extension to colorize validation methods (like `__hard_validation`) so they stand out in the editor.

Example:

```json
"(__hard_validation)": {
 	"filterLanguageRegex": "gdscript",
 	"decorations": [
 		{
 			"color": "#78e2a1d7",
 			"fontWeight": "bold",
 		}
 	]
}
```

Reference configuration can be found in `.vscode/settings.json`.

How it looks:

![alt text](images/vf_highlight.png)
![alt text](images/vf_highlight_3.png)

## 🤔 Ideas Behind Implementation and Trade-offs

I haven't found an easy way to inject framework methods into most common Godot types like `Node` (if this can be done at all). Because of this, we must create a specific extender class for every base node type we plan to use for custom classes (e.g., `NodeSystem`, `Node3DSystem`, `Area3DSystem`).
We cannot simply make a `Node` extender and use it inside a `Node3D` custom class.

This leads to the **major drawback**: the duplication of the framework API across multiple extenders.

![alt text](images/extenders.png)

### Why this is acceptable

- The extender code is identical across types, meaning a change to one leads to copy-pasting to the others. While awkward, this is primitive work and can be managed via strict project guidelines.
- The framework is low-level infrastructural code. Changes are infrequent, making the redundancy and additional maintenance steps more tolerable.
- `ValidationFramework` class contains all the heavy lifting and actual logic. Extender's code acts purely as a "duplicated facade" pointing to that single source of truth.

### Alternative via composition

Another approach would be using composition (e.g., `var validation_framework: ValidationFramework`) or a global Singleton (autoload). This would allow any class to access the framework directly without needing an extender layer.

This approach offers a clearer entity relationship in strict OOP terms: the custom class *depends* on the framework, whereas the current approach makes it seem like the custom class *derives* from the framework.

The custom class would still define methods like `__hard_dependencies` and manually call something like `validation_framework.perform_validation(self)`.

#### Problems

- **Error Prevention:** With composition, a typo in the `__hard_dependencies` function name would make it useless. The current inheritance approach provides auto completion because you override the base class method. By implementing a base method, developers know their `__hard_dependencies` function is part of a rigid structure, not just dangling, unreferenced code.
  - ℹ️ It is planned to make base methods `@abstract`, making it impossible to misspell or forget the implementation.

- **Enforcement:** Composition makes it difficult to force every custom class to use the framework. With the current approach, we could add a call to `__perform_validation` inside `_ready` enforcing its use in the project
  - ℹ️ It is planned for some critical systems.

- **Extensibility:** Extenders give us a unified place to add more shared infrastructural logic beyond just validation, such as logging framework (link to come).

#### Future Proofing

If we ever need to switch to a composition model, the transition would be very easy. The `ValidationFramework` already operates by taking the custom class instance (`self`) as a parameter to process validations. Core validation logic is already fully decoupled from the custom classes and the extender layers.
