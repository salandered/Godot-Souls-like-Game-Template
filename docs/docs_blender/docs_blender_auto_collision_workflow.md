# Blender: Auto creation of collision objects

- [Blender: Auto creation of collision objects](#blender-auto-creation-of-collision-objects)
	- [Description](#description)
	- [Steps](#steps)
		- [Create a Reference Object](#create-a-reference-object)
		- [Reference Object visuals](#reference-object-visuals)
		- [Reference name](#reference-name)
		- [Run script](#run-script)
	- [Script documentation](#script-documentation)
		- [Functions Explained](#functions-explained)

![alt text](<images/how it looks p2.png>)  ![alt text](<images/how it looks.png>)
Blue objects here are result of the script.

## Description

Creates special "collision-only" child objects for every object you have selected.

These objects have a duplicate of the original mesh, have specific material, modifiers, and viewport color copied from a separate, single reference object.

Result objects are placed in a separate collection

![alt text](<images/example in blender.png>)
(looks like this)

⚠️ do not share the same mesh (green triangle) from original object, this creates problems and saves almost nothing. I forgot why

## Steps

### Create a Reference Object

It can be a simple cube. Add modifiers:

- subdivision
- shrinkwrap
- decimate collapse
- decimate planar
- solidify

Example:

![alt text](<images/real col object in use B p2.png>)
![alt text](<images/real col object in use B.png>)

### Reference Object visuals

Assign to a Reference object material with light blue solid color and Viewport Display > Color to blue.

![alt text](images/material.png)
![alt text](<images/wireframe color.png>)

### Reference name

Should be named: `__col_reference`

### Run script

- Select all the main objects that you want to create collision copies for.
- Run the script [auto-collision-script](../../_dev/blender_bible/scripts/auto_collision_script.py)

## Script documentation

1. Looks for the object named `__col_reference`.
1. Finds/Creates a Collection: It looks for a collection named `-- collisions tower--`
1. Gets the list of all mesh objects you currently have selected (ignoring the reference object itself).
1. For each target object that you selected:
	- Creates a new object (`B = target.copy()`) but makes sure it shares the same mesh data as the original (`B.data = target.data`).
	- renames the new object to `[OriginalName]-colonly`.
	- parents the new `-colonly` object to its original object, making sure it stays in the same world position (`parent_keep_transform`).
	- Moves It: It links the new object into the `-- collisions tower--` collection.
	- Copies Properties from Ref:
		 copies the viewport color from your `__col_reference` object.
		 turns on `show_wire` so the new object displays as a wireframe in the viewport.
		 copies all mats from `__col_reference`
		 copies all modifiers from `__col_reference`

### Functions Explained

 `make_colonly_for(target, ref, coll)`: core "factory" function that builds the new `-colonly` object. duplicating, parenting, renaming, calling the helper functions to copy properties.

 `copy_materials_from_ref(ref, obj)`: copies the materials from the `ref` object to the new `obj`. sets the material `link` to `OBJECT`. This allows the new object to have diff mats than the original, even though they share the same mesh data.

 `copy_modifiers_from_to(src, dst)`: mimics the `Ctrl+L` -> "Copy Modifiers" command in Blender. temporarily changes the selection to run the `bpy.ops` command and then restores your original selection.

 `parent_keep_transform(child, parent)`: parents one object to another while calculating the inverse matrix (`matrix_parent_inverse`) needed to keep the child in the same spot.
 `ensure_collection(name)`: helper that checks if a collection exists and creates it if it doesn't.
