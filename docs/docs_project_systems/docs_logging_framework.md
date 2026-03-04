# Logging Framework 📋 <!-- omit from toc -->

- [🧾 What it does](#-what-it-does)
- [🎚️ Log Levels](#️-log-levels)
- [🔌 Framework API via Extender](#-framework-api-via-extender)
	- [Methods to Call (Logging)](#methods-to-call-logging)
	- [Methods to Implement (Config)](#methods-to-implement-config)
- [📞 Direct Calls (Bypassing Extender)](#-direct-calls-bypassing-extender)
- [🎛️ Usage Examples](#️-usage-examples)
	- [Using `NodeLogger` with info/error logs and configuration](#using-nodelogger-with-infoerror-logs-and-configuration)
	- [Direct calls examples](#direct-calls-examples)
- [🧊 Static Loggers](#-static-loggers)
	- [Static classes problem](#static-classes-problem)
	- [Instruction](#instruction)
	- [Usage Example](#usage-example)
- [🤔 About implementation](#-about-implementation)
	- [Log filtering](#log-filtering)

## 🧾 What it does

The Logging Framework provides a centralized way to manage logs across the project.

Main features:

- **Logging Formatting:** Logs are printed using template, which includes meta information like frame number, log level or the custom class name.
- **Logging Handling:** Logging can be toggled on/off for any class (you can also set more broad logging scopes).
- **Friendly API:** Log functions take variadic arguments: any number, any order, any type.
- **Pretty printing of types:** Some info will be 'polished' for readability, such as rounding float numbers or formatting arrays.
- **Optimization / Spam prevention:** Exact sequential messages are not fully printed. This is especially useful for preventing `push_error` spam.
- **Release safety:** info logs are excluded from release builds.

## 🎚️ Log Levels

From low to high:

- ⬜ `SILENT`: "Meta" level which does nothing. Use with caution.
- 🟦 `INFO`: Basic info log message. Used for general debugging and state tracking.
- 🟨 `WARN`: Prints a warning message with an icon.
- 🟨 `WARN_CRUCIAL`: Prints a warning message with a prominent icon _(in docs that started sounding funny, idea is this is an error, but not `PUSH_ERROR`, probably would be renamed to ERROR)._
- ⬛ `ASSERT`: Triggers a fast crash using GDScript `assert`. Duplicates message as if it was `WARN`.
  - ℹ️ Intended for use only while prototyping. Discouraged even in developer builds.
- 🟧 `PUSH_WARN`: Uses Engine-level warnings. All info about `PUSH_ERROR` applies here as well.
- 🟥 `PUSH_ERROR`: Uses Engine-level errors. Most robust way to treat an error, in particular useful for domain-agnostic utilities as these levels provide a stack trace.
  - ℹ️ Will still print message using all framework features like formatting.
  - ⚠️ There is a known issue when running the app via VSCode (godot-tools), when an excessive error pushing (e.g.,every frame) can severely stutter not only a game, but OS.

## 🔌 Framework API via Extender

Similar to the Validation Framework, custom class should extend a built-in class extender (like `NodeLogger` or `NodeSystem` as any `XSystem` extender inherits the logger as well).

### Methods to Call (Logging)

Functions to call to use logging:

- 🟦 `__log_(_prefix: Variant, ...parts: Array)`: Corresponds to the `INFO` level. `_prefix` will be formatted as a 'key phrase' before the actual log message.

- 🟨 `__log_warn_soft(what: String, where: String = "", fallback: String = "", ...context: Array)`: Corresponds to the `WARN` level.

- 🟧 `__log_warn(what: String, where: String = "", fallback: String = "", ...context: Array)`: Corresponds to the `PUSH_WARN` level.

- 🟥 `__log_error(what: String, where: String = "", fallback: String = "", ...context: Array)`: Corresponds to the `PUSH_ERROR` level.

ℹ️ Unlike the info level  `__log_`, all error logs have an additional template built into the interface.

- This helps a developer to provide necessary info.
- The structure will be pretty printed to the final message so it looks natural.
- While sometimes cumbersome, it may save you the words, as error message usually contains these sematic points.
- Framework auto attaches meta information to the `where` part: calling `__log_warn("oh")` is fine.
- All the raw additional info still can be added using the last variadic argument

### Methods to Implement (Config)

Optionally override these base extender methods:

- `__LOG_B() -> bool` (default `true`): Toggles logging on and off..
- `__LOG_INDENT() -> int` (default `0`): Returns the number of tabs to indent the printed logs (just QoL).
- `pp_name() -> String` (default is `class_name` if can be found or `undefined`): Returns the "pretty print" name of the class.

## 📞 Direct Calls (Bypassing Extender)

> [!NOTE]
> This calls also go through the single framework, it is ok to use them (there is only one built-in `print` call in the whole project)
<!-- lint fight -->
> [!IMPORTANT]
> Looks like a zoo for historical reasons. Planned to be simplified.

Using direct calls bypass the extender layer:

- can be used in the class that does not use extender like `NodeLogger`
- lacks extender related formatting features
- some additional configuration can be specified

Using `print_`:

- 🟦 `print_.msg_raw(...parts: Array)` - prints raw messages.
- 🟦 `print_.msg_formatted(prefix_: String, text: String = "", info_indents: int = 0)` - prints a manually formatted message.

Using `print_err`:

- 🟧 `print_err.msg_formatted(msg: String, warn_level: StringName)` - allows any log level.

Using `error_`:

- 🟧 `static func warn(what: String, where: String, fallback: String, warn_level: StringName = WL.PUSH_ERROR,...details: Array)` - allows error template and any log level. Usually is used in utilities.

## 🎛️ Usage Examples

### Using `NodeLogger` with info/error logs and configuration

```GDscript
class_name MusicSystem
extends NodeLogger

var bus_id := "SFX"
var play_on_start := true
var stream_to_volume := {
	"footstep": 2.0,
	"jump": - 3.0
}
var default_stream: AudioStream

func _ready() -> void:
	# info logs, any args, any order
	__log_("init", "bus_id/autoplay/stream_to_volume", bus_id, play_on_start, stream_to_volume)
	__log_("init", "default_stream is", default_stream.resource_name, default_stream)
	
	if not default_stream:
		# Will push engine Warning. 
		# Actual message would be like: 
		#   "⚠️💥 Problem: no stream!. Where: 🎶MusicSystem | init". Fallback: returning"
		__log_warn("no stream!", "init", "returning")
		return
	if bus_id == "Master":
		# Soft warning with minimal message (not error pushing). 
		__log_warn_soft("bus id is Master")
		# Or adding any context as well.
		__log_warn_soft("bus id is Master", "", "", bus_id, play_on_start, stream_to_volume)

## LOG CONFIGURATION

func pp_name() -> String:
	return "🎶MusicSystem" # <- every log will use this

func __LOG_B() -> bool:
	return false # info logs are not printed. (warn/error logs will be)
```

### Direct calls examples

There are self explanatory :)

## 🧊 Static Loggers

Using logs via extenders are also supported in a similar way.
Custom static class should extend a static extender like `RefCountedStaticLogger`.

### Static classes problem

GDScript does not support overriding static methods: framework cannot dynamically resolve a subclass's static config methods (like `pp_name` or `__LOG_B`).

This makes the current implementation for static loggers more boilerplate-heavy.

ℹ️ It is planned to make it better

### Instruction

Copy-paste a specific `__LOGS` template region into your script (see any extender). It defines the local configuration and the `__log_` function itself.

Warn/error logging methods (like `__log_warn`) are still inherited from the extender and can be used the same way as with non static class. Minor issue is that they won't use `pp_name`.

### Usage Example

```GDscript
class_name PositiveNumberLover
extends RefCountedStaticLogger

static func take_my_positive_number(number: int) -> void:
	if number <=0 :
		__log_error("number is negative or 0", "take_my_positive_number", "return")
		return
	
	__log_("take_my_positive_number", "got the number:", number)

# CONFIG

static func pp_name() -> String:
	return "PositiveNumberLover" # <- explicit duplication

static func __LOG_B() -> bool:
	return true

static func __log_(...):
	# <from template>
```

## 🤔 About implementation

Logger framework follows the same pattern as Validation Framework.
Read about it here here: [link](docs_validation_framework.md)

### Log filtering

Framework is ready for adding log filtering feature. This is work in progress.
