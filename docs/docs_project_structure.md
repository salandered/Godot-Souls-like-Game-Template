# 🗃️ Folder structure <!-- omit from toc -->

- [Main folders](#main-folders)
- [`logic/` folder structure](#logic-folder-structure)
	- [🏰 \_project\_data/](#-_project_data)
	- [📦 containers/](#-containers)
	- [🧠 systems/](#-systems)
	- [👸🏻 entities/](#-entities)
	- [🖥️ ui/](#️-ui)
	- [🏗️ dev\_systems/](#️-dev_systems)
	- [🔨 utils/](#-utils)

## Main folders

📜 [_attribution](../_attribution) - information about attributions, licenses and credits

🎢 [_workflow](../_workflow/) - covers Blender to Godot workflow, post import script and editor-only utilities like working with images or materials

💎 [assets](../-assets-/) - all assets, including meshes, animations, SFX and music

🔧 [addons](../addons/) - all third party addons, if they were changed (vanilla addons are not committed)

📚 [docs](../docs/) - all documentation, including this one

⚔️ [logic](../logic/) - main application code: infrastructure code, game systems, developer tools.

## `logic/` folder structure

The primary directory for all application code, with the exception of the `_workflow/` folder which contains scripts.

Note that the distinction here is a work in progress. Currently I settled on this structure.

### 🏰 [_project_data/](../logic/_project_data)

Contains core infrastructure: non-gameplay systems that keep the application running, like scene loader, audio bus management, global signals [event bus], custom frameworks.

Some of these systems are based on Maaacks game template. See docs: [docs_maaacks_game_template](docs_game_systems/docs_maaacks_game_template.md)

[Logger](docs_project_systems/docs_logging_framework) and [validation](docs_project_systems/docs_validation_framework.md) frameworks are stored here.

Currently all the autoloads are also contained in this folder.

### 📦 [containers/](../logic/c_containers)

Store all the classes that contain the data and provide the access to it.

Can be seen as 'Repositories', but mostly there are read-only. Probably better name would be 'Data store' or 'Registry'.

All the data enums and 'json' like structures are also stored here (just a primitive data storage)

### 🧠 [systems/](../logic/c_systems)

Core game logic (business logic): character state machines, camera management, all the possible mechanics. Biggest component of the project.

Word 'System' here can be seen as a Service. Systems are usually stateless and relies on `containers/`.

In DDD terms it can be said that `systems/`, `containers/` and `entities/` describe the domain.

### 👸🏻 [entities/](../logic/entities)

All the characters, levels, props (like torches or levers) and items (weapons). This means scenes, some "prefabs", visuals.
Also stores VFX effects like an aura wave or smoke effects.

All non code data (basically visuals) is derived from the `assets/` folder and usually has a connection to GLB files.

### 🖥️ [ui/](../logic/ui)

Contains all the menus (main menu, options menu, pause menu), theme data, elements like buttons etc.

In theory this violates the structure above: can be split in services, data containers and entities. But currently this works.

This group can be treated as all of the `Control` (Godot node type) scenes and their logic.

### 🏗️ [dev_systems/](../logic/x_dev_systems)

Contains developer data and tools (in contrast with business logic of the `systems/`).

Examples: metrics gathering, debug visualizers, sometimes even 'mechanics', like a flying mode or additional cameras and lighting setup which can be attached to the characters.

Should be stripped from the release builds.

### 🔨 [utils/](../logic/x_utils)

Utilities which are used by every other component. They tend to be _specific_, i.e each one does one thing and tries to do it good and _agnostic_, i.e not knowing about the domain.

Examples:

- helpers for working with primitive types
- helpers for working with built-in nodes
- technical utilities like value interpolators or event throttlers.

Sometimes they 'extend' or 'shape' we work with the code, like safe type casters for nested objects or return objects in 'go' style (wrappers around primitive types with an ability to return error)
