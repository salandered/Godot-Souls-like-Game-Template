# Working with signals ☄️ <!-- omit from toc -->

- [🏛️ About signals architecture](#️-about-signals-architecture)
- [📄 Signal Naming](#-signal-naming)
- [💼 Signal Payload](#-signal-payload)
	- [Why](#why)
	- [Payload schema](#payload-schema)
- [📡 Working with signals](#-working-with-signals)
	- [Signal operations](#signal-operations)

## 🏛️ About signals architecture

I wrote a series of blog posts:

- How signals can be used applying Event Driven Architecture perspective: [link](https://salandered.github.io/posts/godot-signals-and-eda/)
- Signal usage via event bus: [link](https://salandered.github.io/posts/godot-signals-and-event-bus/)
- About structured payload: [link](https://salandered.github.io/posts/godot-signals-and-payload/)

## 📄 Signal Naming

Official docs recommend using names like  `door_opened` or `health_depleted`. This mimics the built-in signals (`area_entered`).

In project we use the prefix `SIG_`. Example: `SIG_door_opened`

- helps with readability
- helps to distinguish custom signals from the built in ones
- ℹ️ violates the lower case conventions: Is planned to be switched to `sig_`

💡 As mentioned, naming uses a verb in the past tense (some fact has happened). But signals can also be used to describe the **command pattern** (intention).
Currently it is not formalized in the project.

## 💼 Signal Payload

All signals have the same payload structure: `Dictionary[StringName, Variant]`, if payload is present.

### Why

- unifies all signal handlers
- unifies the way payload is parsed (see `SigUtils`)
- prevents errors when handler signature does not match the signal
- prevents errors while parsing payload (`SigUtils` are safe)

🤔 Trade-off: significant amount of the boilerplate code.

### Payload schema

While real schemas are not implemented, currently we use predefined constants as payload keys.
See `SPS` (Signal Payload Schema) class.

Object which uses its own signals, may also define such fields. But they should be easily accessed by any subscriber.

## 📡 Working with signals

### Signal operations

All basic operations should be done only through the `SigUtils` utilities.

Basic operations:

- connecting/disconnecting signals
- emitting signals
- parsing payload

`SigUtils` is error safe and contains all the necessary 'weaponry'. It also contains some dev tools, which means that if signal emitting bypasses the utility, the information will be lost.
