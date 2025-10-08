---
applyTo: '**'
---
## Project context
This project is a Godot engine game written in GDScript. It is a souls-like 3D game with a focus on nice character controller and combat mechanics.

## Version compliance
We use Godot version 4.5. Usually this means any 4+ info will be compatable.
Important: Changes should be according to the official docs: https://docs.godotengine.org/en/stable/

## Project structure
All scripts and logic are in "logic/" folder. You don't need to see any other root folders.
All scripts have .gd extension. These are the only files you need to edit and / or take into account. In particular, ignore .tscn files (scene files) or .tres files (resource files).
"SE" stands for Simple Enemy. 

## Indentations
We use tabs, not spaces.
This is a tab character: '	'
This is a space character: ' '
Use only tabs for indentations, no spaces at all!

## Coding style
* Rule of thumb: use the style of a project.
* don't check for null variables which must be there by design.
* aim to ~100 characters line length max. 
* do not delete current comments while editing or refactoring code.

## Philosophy
Aim for a good enough solution, not the perfect one.