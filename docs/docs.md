# Developer Documentation <!-- omit from toc -->

- [🛠️ Tech Stack](#️-tech-stack)
	- [Godot](#godot)
	- [Godot addons](#godot-addons)
	- [VSCode](#vscode)
	- [Blender](#blender)
	- [Image editors](#image-editors)
- [📘 Code conventions and best practices](#-code-conventions-and-best-practices)
- [🗃️ Project organization](#️-project-organization)
	- [Folder structure](#folder-structure)
	- [Folder Conventions](#folder-conventions)
		- [Scene naming](#scene-naming)
		- [Misc](#misc)
- [AI Usage](#ai-usage)

## 🛠️ Tech Stack

### Godot

**Godot** v4.6.1

### Godot addons

**Committed addons (changes were made):**

- [gd-pixpal-tools-addon](https://github.com/Flynsarmy/gd-pixpal-tools-addon)
- [Godot Console](https://github.com/jitspoe/godot-console)

**Necessary addons:**

- [GUT - Godot Unit Testing](https://godotengine.org/asset-library/asset/1709)
  - doc about unit testing is planned.

See also about Maaacks Game Template [here](docs_project_systems/docs_maaacks_game_template.md)

**QoL:**

ℹ️ Not all of them survived Godot 4.6 update.
Planned to delete, adopt (untie from addons) or make contribution.

- [Blender 3D Shortcuts](https://godotengine.org/asset-library/asset/1106)
- [Blender viewport shortcuts](https://godotengine.org/asset-library/asset/4728)
- [Fancy Folder Colors](https://godotengine.org/asset-library/asset/3859)
- [Favorite Scenes](https://godotengine.org/asset-library/asset/3363)
- [Instance Dock](https://godotengine.org/asset-library/asset/1421)
- [TODO_Manager](https://github.com/OrigamiDev-Pete/TODO_Manager)

### VSCode

VSCode is used with **godot-tools** plugin.

> [!NOTE]
> See VSCode docs [here](docs_vscode.md).

### Blender

> [!NOTE]
> See Blender docs [here](docs_blender.md)

### Image editors

Anything can be used. I use **Krita** version 5.x and **ImageMagic**

## 📘 Code conventions and best practices

> [!NOTE]
> See docs [here](docs_code_convention.md)

## 🗃️ Project organization

### Folder structure

> [!NOTE]
> See docs [here](docs_folder_structure.md)

### Folder Conventions

Follows official [docs](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)

#### Scene naming

Notable exception: scene resources ([.tscn](https://docs.godotengine.org/en/stable/engine_details/file_formats/tscn.html#tscn-file-format)) are saved using **PascalCase**. That means that saved scene name is the same as the root node name of that scene.

- It seemed natural and improves file system readability, but also [a bad practice](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#case-sensitivity).
- => project will be switching to **snake_case** in the future.

#### Misc

Note: In project settings default naming convention is **kebab-case**, you can ignore this ([see also](https://github.com/godotengine/godot-docs-user-notes/discussions/205#discussioncomment-12416138)).

## AI Usage

Not using AI for writing domain code, but secondary activities are fine.

In particular, it's useful to set up read-only MCP server with latest Godot docs and use the AI as a 'librarian'.

All the instructions are in this repo: [Godot MCP Docs](https://github.com/Nihilantropy/godot-mcp-docs).

- Godot/GDScript are not the most popular tools, and it shows in search results ([poorly](https://www.reddit.com/r/godot/comments/1bdfh5q/comment/l7ziuhs/) [indexed](https://www.reddit.com/r/godot/comments/1bdfh5q/comment/lg11lwj/)) and the AI training.
- "Raw" AI tend to mix all Godot versions including Godot 3 or early 4.x (i.e that variadic arguments are not supported)

> [!WARNING]
> It is discouraged to use MCP servers which expose _**write access**_ to Godot or any other system
