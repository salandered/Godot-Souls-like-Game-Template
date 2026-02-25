## Godot Engine instructions

### Ignoring specific folder

Create empty `.gdignore` file in the folder root. See [docs](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html#ignoring-specific-folders)

### 'Undo' problem

**Problem:** Godot ignores **undo** command for some operations, like when working with the file system.

This leads to:

1. add a marker to animation
1. move some file in FS
1. make **undo**, trying to bring file back

Result: marker deleted (not added) and file is not moved.
Second step can be done hours after the first step. This means that you won't notice the marker dissapearance.

**Solution:** Make history tab visible in godot editor and always check what ctrl Z does.

### Working with file system

Any changes to file system should be done [only](https://docs.godotengine.org/en/stable/tutorials/scripting/filesystem.html#drawbacks) via Godot UI FileSystem view.

> Never move assets from outside Godot, or dependencies will have to be fixed manually

### Deleting folder with hidden file

**Problem**: By default Godot FS doesn't show files with extensions which engine does not support.
If you have such files in godot files, it may seem, that folder is empty.
Usually this can be the case in documentation folder or blender folder which contains .py files.

**Solution**: Check folder content using OS file system before deleting the folder (deleting should be via Godot FS)
