---
applyTo: '**'
---
## Project context
This project is a Godot engine game written in GDScript. It is a souls-like 3D game with a focus on nice character controller and combat mechanics.

## Versions 
We use Godot version 4.4.

## Indentations
We use tabs, not spaces. Don't use space for indents!

## Coding style
Rule of thumb: check the existing code in the same file or similar files. But mostly we use snake_case for variable names and functions, and PascalCase for class names. Constants are written in UPPER_SNAKE_CASE. 

## Writing new code
It is recommended to check the documentation for Godot 4.4 for complex changes of the built in classes and methods.

## Specific code guidelines
* don't check for null variables which must be there by design. Check once in ready() or not check at all.
* aim to 80 characters line length. (if you need longer: use variables, new lines '\', place comments above a line, etc)
* do not delete my comments while editing or refactoring code.