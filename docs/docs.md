# Developer Documentation <!-- omit from toc -->

- [🛠️ Tech Stack](#️-tech-stack)
	- [Godot](#godot)
	- [VSCode](#vscode)
	- [Blender](#blender)
	- [Image editors](#image-editors)
- [✍️ Instructions](#️-instructions)
- [📘 Code conventions and best practices](#-code-conventions-and-best-practices)
- [🗃️ Project organization](#️-project-organization)
	- [Project Structure](#project-structure)
	- [Folder / File Conventions](#folder--file-conventions)
		- [Exception: Scene naming](#exception-scene-naming)
- [AI Usage](#ai-usage)

## 🛠️ Tech Stack

### Godot

**See Godot docs: [docs_godot_engine_instructions 💙](docs_project_systems/docs_godot_engine_instructions.md)**

### VSCode

VSCode is used with **godot-tools** plugin.

**See VSCode docs: [docs_vscode 🔷](docs_vscode.md)**

### Blender

**See Blender docs: [docs_blender 🍊](docs_blender/docs_blender.md)**

### Image editors

Anything can be used I guess. I use **Krita** version 5.x and **ImageMagic**

## ✍️ Instructions

**All system docs and instructions are here: [docs_project_systems/](docs_project_systems)**

Essentials:

- [docs_signals ☄️](docs_project_systems/docs_signals.md)
- [docs_validation_framework 🛡️](docs_project_systems/docs_validation_framework.md)
- [docs_godot_engine_instructions 💙](docs_project_systems/docs_godot_engine_instructions.md)
- [docs_optimization_techniques 📉](docs_project_systems/docs_optimization_techniques.md)

## 📘 Code conventions and best practices

**See docs: [docs_code_convention 📘](docs_code_convention.md)**

## 🗃️ Project organization

### Project Structure

**See docs: [docs_project_structure 🗃️](docs_project_structure.md)**

### Folder / File Conventions

Follows [official docs](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html).

#### Exception: Scene naming

Scene resources ([.tscn](https://docs.godotengine.org/en/stable/engine_details/file_formats/tscn.html#tscn-file-format)) are saved using **PascalCase**. That means that saved scene name equals to its root node name.

- It seemed natural and improves file system readability, but also [a bad practice](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#case-sensitivity).
- => It is planned to switch to **snake_case**

> [!TIP]
> In project settings default naming convention is **kebab-case**, you can ignore this ([see also](https://github.com/godotengine/godot-docs-user-notes/discussions/205#discussioncomment-12416138)).

## AI Usage

Not using AI for writing domain code, but secondary activities are fine.

In particular, it's useful to set up read-only MCP server with latest Godot docs and use the AI as a 'librarian'.

Instructions can be found here: [Godot MCP Docs](https://github.com/Nihilantropy/godot-mcp-docs).

"Raw" AI chats tend to mix Godot versions including Godot 3 and early 4.x (i.e they don't know that variadic arguments are supported). Godot/GDScript are not relatively popular, it shows in the AI training (and [search](https://www.reddit.com/r/godot/comments/1bdfh5q/comment/l7ziuhs/) [results](https://www.reddit.com/r/godot/comments/1bdfh5q/comment/lg11lwj/)).

ℹ️ It is not recommended to use MCP servers which expose _**write access**_ to OS, Godot or any other application.
