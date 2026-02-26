# Signals docs ☄️ <!-- omit from toc -->

- [📄 Signal Naming](#-signal-naming)
- [💼 Signal Payload](#-signal-payload)
	- [Why](#why)
	- [Payload schema](#payload-schema)
- [📡 Working with signals](#-working-with-signals)
	- [Signal operations](#signal-operations)
	- [Connecting signals in UI](#connecting-signals-in-ui)
	- [Signal scope](#signal-scope)
- [🤔 Additional thoughts on a signal scope usage](#-additional-thoughts-on-a-signal-scope-usage)
	- [🌎 Global scope](#-global-scope)
		- [Relying on entity ID](#relying-on-entity-id)
	- [🚪 Entity specific scope](#-entity-specific-scope)
		- [Why using signals at all?](#why-using-signals-at-all)
		- [Using signals with dependency injection](#using-signals-with-dependency-injection)
		- [Local Event bus via third component (container)](#local-event-bus-via-third-component-container)

## 📄 Signal Naming

Starts with `SIG_`.

- helps with readability
- helps to distinguish custom signals from the built in ones
- ℹ️ violates the naming convention for variables

Usually should use a verb in a past tense.

- Signal represents an **event pattern** in Godot, meaning that some fact has happened.

In theory there can be used to describe the **command pattern** (intention), but currently it's not formalized in the project.

## 💼 Signal Payload

All signals have the same payload structure: `Dictionary[StringName, Variant]`, if payload is present.

### Why

- unifies all signal handlers
- unifies the way payload parsed (see `SigUtils`)
- prevents errors when handler signature does not match the signal
- prevents errors while parsing payload (`SigUtils` are safe)

Trade-off:

- significant amount of the boilerplate code (still think it was worth it)

### Payload schema

While real schemas are not implemented, currently we use predefined constants as payload keys.
See `SPS` (Signal Payload Schema) class.

Entity which uses its only signals, may also define such fields. But they should be easily accessed by any subscriber.

## 📡 Working with signals

### Signal operations

All the work should be done only through the `SigUtils` utilities.

Basic operations:

- connecting/disconnecting signals
- emitting signals
- parsing payload

`SigUtils` is error safe and contains all the necessary 'weaponry'. It also contains some dev tools, which means that if signal emitting bypasses the utility, the information will be lost.

### Connecting signals in UI

Godot has a cool feature of connecting the signals via UI, which means that `connect` api is not called in the code at all. This is very useful for a quick prototyping, but ones the things 'are settled', it is strongly advised to **make the connection in code**.

- UI connection makes it implicit: you don't know how code works outside the engine.
- Code refactoring in VSCode may lead to connection loss (Even if you work in Godot Engine).

⚠️ This is especially important while working in VSCode, because you don't have a UI hint in code editor. Handler would look like a dead code (no usages).

### Signal scope

Basically we use two different scopes: global signals and signals which are attributes of an entity (like button or door).

🌎 Global scope is implemented as [`GlobalSignal` class](../logic/_project_data/autoload/global_signal/global_signal.gd).

This is similar to an **event bus pattern** while can be seen as a very primitive implementation (an autoload with signal variables). See this comment describing the same idea: [comment](https://github.com/godotengine/godot-docs-user-notes/discussions/5#discussioncomment-8124099)

🚪 Entity scope means that a signal belongs to specific class instance, i.e `AudioOptionButton.button_pressed`

Practices of the scope usages are work in progress: event driven architecture is prone to making wrong assumptions, and combining it with learning how to use Godot signals and rapid project growth results in one big uncertainty.

Currently the rule of thumb is:

- 🌎 Global signals are used in _many-to-x relationships_ to tie any logic to any event, _regardless of how subscriber and publisher relate to each other_ in code, tree structure, or domain. They can be a part of completely different systems from different bounded contexts.
  - Example: pressing a UI button leads to playing a sound. Sound player does not care which button was pressed and what menu was used, and probably can be not related to UI logic at all.
- 🚪  Entity scoped signals are used when subscriber has some relation to the publisher which can be 'described' in code or logic terms. Usually have entity identification in the payload.
  - Example: Audio option button press leads to opening audio option sub menu. The subscriber (i.e `OptionSubmenuLoader`) needs to know about that specific button and they are both probably a part of the UI options menu.

## 🤔 Additional thoughts on a signal scope usage

### 🌎 Global scope

Useful when subscriber and publisher does not have any direct dependency between each other, meaning that subscriber can not directly access publishers signal (i.e. via code like `my_dependent_door.door_opened.connect(my_handler)`)

Usually represents the **many-to-one/many-to-many** relationships, i.e. several publishers can publish the same event.

Probably does not contain entity specific information (or at least subscribers should not rely on it).

- Example: emitting global `door_opened` signal when it does not matter, which door has been opened.
- Subscriber could be **SteamAchievements** service, which counts how many doors player has opened during the playthrough.

#### Relying on entity ID

Containing entity specific information still can be a case: imagine metric manager which analyses which menu buttons player presses the most. In this case buttons could emit global signal `button_pressed` containing button ID information.

But it comes with a catch: implementing scenario above may lead the developer to use the same signal in the "audio options" example. In this case `OptionSubmenuLoader` subscribes to the global `button_pressed` signal, but opens audio options only if `button_id == "AudioOptionsButton"`. This can quickly go out of control, because every button would trigger `OptionSubmenuLoader` loader, leading to performance issues and probably convoluted code.

### 🚪 Entity specific scope

**One-to-one/one-to-many** relationships when subscribers depend on a specific publisher.

Usually are used when entity specific information matters.

Using the door example, imagine we have a **SFX system** which is a part of a door scene. It subscribes to the specific `Door.door_opened` signal and plays a sound on receiving such a signal. Obviously it can't subscribe to the `GlobalSignal.door_opened`: one opened door would trigger opening sound on every existing door in the level.

#### Why using signals at all?

It may seem, that in door SFX case the signal is not necessary at all. **Door** could just call its **SFX system** (probably a child node) after the door started to open (i.e. `SFXService.play_door_opening_sound()`). While this may be true on a small scale, using event systems between services which has direct access to each other (i.e inside the one scene) still has all the advantages of the decoupled system:

- **SFX service** depends on the **Door**, not the other way around
- **Door** should not know about the **SFX system** and can work without it (i.e silent door), direct call in **Door** code would violate this
- **SFX service** is just one example, we can have **VFX system** which creates dust effect on door opening and so on, managing all dependencies and calls on the door side could become cumbersome.

Another counter argument might be that indie game is a one big monolith. You may not use any signals at all: every part of the system can be accessed directly using global tree object, autoloads (singletons) or Godot `groups`. You don't have a network connection and miles of physical distance between the code parts. Signals look like the best way to achieve that decoupled 'microservices' vibe in a Godot game app.

#### Using signals with dependency injection

A case when **Door** has **SFX system** as a dependency still can be valid. Let's assume that **SFX system** is reused between different items and same SFX implementation is used not only for doors: **SFX service** doesn't know about doors, but is good at playing sounds from some library (e.g. it maps signal name to sound type using some predefined global map). We can 'turn around' the **Door** to **SFX Service** dependency using signals and dependency injection. **Door** injects its signal while initializing **SFX system**. In this case Door still does not call `SFXSystem.play_sound` directly and does not really care about **SFXService** after its initailisation.

#### Local Event bus via third component (container)

Door has many signals (like `door_closed`, `door_locked` etc) and many systems which work with them. Then **DoorSignalContainer** can be created. Any system like **SFXSystem** will use this injected container in order to do its own thing. This looks like it leads to 'invention' of the event bus, but this time it's not global, and have an item (a door) scope.
