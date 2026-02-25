# Developer Documentation <!-- omit from toc -->

- [🛠️ Tech Stack](#️-tech-stack)
	- [Godot](#godot)
	- [VSCode](#vscode)
	- [Blender](#blender)
	- [Image editors](#image-editors)
- [📘 Code conventions and best practices](#-code-conventions-and-best-practices)
- [🗃️ Project organization](#️-project-organization)
	- [Folder structure](#folder-structure)
	- [Folder Conventions](#folder-conventions)
		- [.tscn naming](#tscn-naming)
		- [misc](#misc)
- [👾 AI Usage](#-ai-usage)

## 🛠️ Tech Stack

### Godot

Godot v4.6.1

### VSCode

VSCode is used with a **godot-tools** plugin. (I haven't tried [Rider](https://www.jetbrains.com/lp/rider-godot/))
See The reasoing behind VSCode here: [text](docs_vscode.md)

### Blender

> [!NOTE] See [docs_blender](docs_blender.md)

### Image editors

Anything can be used. I usually use Krita version 5.x and ImageMagic

## 📘 Code conventions and best practices

> [!NOTE] See [code_convention_docs](docs_code_convention.md)

## 🗃️ Project organization

### Folder structure
>
> [!NOTE] See [docs_folder_structure](docs_folder_structure.md)

### Folder Conventions

Follows official [docs](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)

#### .tscn naming

Notable exception: scene resources ([.tscn](https://docs.godotengine.org/en/stable/engine_details/file_formats/tscn.html#tscn-file-format)) are saved using **PascalCase**. That means that saved scene name is the same as the root node name of that scene.

- It seemed natural and improves file system readability, but also [a bad practice](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#case-sensitivity).
- => Probably project will be switching to **snake_case** in the future.

#### misc

Note: In project settings default naming convention is **kebab-case**, you can ignore this ([see also](https://github.com/godotengine/godot-docs-user-notes/discussions/205#discussioncomment-12416138)).

## 👾 AI Usage

We don't use AI for writing main code (business logic and such), but it still can be used for some secondary activities.

In particular, it's proved to be useful to set up MCP server with latest Godot docs and use AI as a 'librarian'.
All the instructions can be find in this repo: [Godot MCP Docs](https://github.com/Nihilantropy/godot-mcp-docs).

- Godot/GDScript are not the most popular tools, and it shows in search results ([poorly](https://www.reddit.com/r/godot/comments/1bdfh5q/comment/l7ziuhs/) [indexed](https://www.reddit.com/r/godot/comments/1bdfh5q/comment/lg11lwj/)) and the AI training.
- If asking AI directly about the docs, it will use outdated Godot 3 or early 4.x information, saying things like variadic arguments are not supported.
