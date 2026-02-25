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

🎢 [_workflow](../_workflow/) - covers Blender to Godot workflow, post import script and other utilities (like `EditorScript` files)

💎 [assets](../-assets-/) - all assets, including meshes, animations, SFX and music

🔧 [addons](../addons/) - all third party addons, if they were changed (vanilla addons are not committed)

📚 [docs](../docs/) - all documentation, including this one

⚔️ [logic](../logic/) - main application code: all game systems, entities and repositories (services, scenes and containers)

## `logic/` folder structure

The primary directory for all application code, with the exception of the `_workflow/` folder which contains scripts.

Note that the distinction here is a work in progress. Currently I settled on this structure.

### 🏰 [_project_data/](../logic/_project_data)

Contains core infrastructure: non-gameplay systems that keep the application running, like scene loader, audio bus management, global signals [event bus] and configuration settings.

Note that some of these systems are based on Maaacks game template. See docs: [docs_maaacks_game_template](docs_game_systems/docs_maaacks_game_template.md)

Currently all the autoloads are also contained in this folder.

### 📦 [containers/](../logic/c_containers)

Store all the data for systems and entities, and provide the access to it.

Can be seen as 'Repositories', but mostly there are read only. Probably could've been called 'Registry' or 'Catalogs'.

All the data enums and 'json' like structures are also stored here (just a primitive data storage)

### 🧠 [systems/](../logic/c_systems)

Core game logic (business logic): character state machines, camera management, all the possible mechanics. Biggest component of the project.

Word 'System' here can be seen as a Service. Systems are usually stateless and relies on `containers/`.

In DDD terms it can be said that `systems/`, `containers/` and `entities/` describes the domain.

### 👸🏻 [entities/](../logic/entities)

"The nouns of the game".

All the characters, levels, props (like torches or levers) and items (weapons). This means scenes, some "prefabs", visuals.
Also stores VFX effects like an aura wave or smoke particles.

All non code data (basically visuals) is derived from the `assets/` folder and usually has a connection to GLB files.

### 🖥️ [ui/](../logic/ui)

Contains all the menus (main menu, options menu, pause menu), theme data, elements like buttons etc.

In theory this violates the structure above, because it can be split in services, data containers and entities as well. But currently this works.

This group can be treats as all of the 'Control' (Godot node type) related processes and data of the application.

### 🏗️ [dev_systems/](../logic/x_dev_systems)

Contains developer data and tools (in contrast with business logic of the `systems/`).

Examples: metrics gathering, debug visualizers, sometimes even 'mechanics', like flying player mode or additional cameras and lighting setup which can be attached to the characters.

Should be stripped from the release builds.

### 🔨 [utils/](../logic/x_utils)

All utilities, which are used by every other component as helpers. They tend to be very specific, i.e each one does one thing and tries to do that the best way possible and agnostic, i.e not knowing about the domain and processes

Examples: helpers for working with primitive types or basic built-in nodes or technical objects like value interpolators or event throttlers.

Sometimes they 'extend' or 'shape' we work with the code, like type casters for nested objects or return objects in 'go' style (wrappers around primitive types with an ability to return error)
